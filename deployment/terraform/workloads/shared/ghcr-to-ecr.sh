#!/bin/bash

# Define variables
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
ECR_REPOSITORY_PREFIX="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Authenticate Docker with AWS ECR
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REPOSITORY_PREFIX"

# Define image sources and destinations using a normal array
IMAGES=(
  "ghcr.io/fivexl/n-example-voting-app-result:after result:v0.27"
  "ghcr.io/fivexl/n-example-voting-app-worker:latest worker:v0.27"
  "ghcr.io/fivexl/n-example-voting-app-vote:after vote:v0.27"
)

# Pull, tag, and push images
for IMAGE_PAIR in "${IMAGES[@]}"; do
  SRC_IMAGE=$(echo "$IMAGE_PAIR" | awk '{print $1}')
  DEST_IMAGE=$(echo "$IMAGE_PAIR" | awk '{print $2}')
  ECR_IMAGE="$ECR_REPOSITORY_PREFIX/$DEST_IMAGE"

  echo "Processing $SRC_IMAGE -> $ECR_IMAGE"

  docker pull --platform linux/amd64 "$SRC_IMAGE"
  docker tag "$SRC_IMAGE" "$ECR_IMAGE"
  docker push "$ECR_IMAGE"
done

echo "All images have been pushed to AWS ECR."
