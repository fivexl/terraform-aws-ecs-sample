#!/usr/bin/env bash

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 471112922998.dkr.ecr.eu-central-1.amazonaws.com
docker compose build --pull
docker compose push