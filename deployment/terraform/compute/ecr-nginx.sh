aws ecr create-repository \
    --repository-name nginx \
    --region eu-central-1

aws ecr get-login-password --region eu-central-1 | docker login \
    --username AWS \
    --password-stdin 471112922998.dkr.ecr.eu-central-1.amazonaws.com

docker pull nginx:latest

docker tag nginx:latest 471112922998.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest
docker push 471112922998.dkr.ecr.eu-central-1.amazonaws.com/nginx:latest



