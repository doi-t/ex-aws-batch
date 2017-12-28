#!/bin/bash
set -e
ECR_REPO_NAME=ex-aws-batch
if ! aws ecr describe-repositories --repository-names $ECR_REPO_NAME; then
    aws ecr create-repository --repository-name $ECR_REPO_NAME
fi
aws ecr describe-repositories --repository-names $ECR_REPO_NAME
ECR_REPO=`aws ecr describe-repositories --repository-names $ECR_REPO_NAME | jq ".repositories[].repositoryUri" -r`
docker build --tag $ECR_REPO .
docker images
`aws ecr get-login --no-include-email`
docker push $ECR_REPO
MANIFEST=$(aws ecr batch-get-image --repository-name $ECR_REPO_NAME --image-ids imageTag=latest --query images[].imageManifest --output text)
GIT_COMMIT_HASH=`git rev-parse HEAD`
aws ecr put-image --repository-name $ECR_REPO_NAME --image-tag $GIT_COMMIT_HASH --image-manifest "$MANIFEST"
aws ecr describe-images --repository-name $ECR_REPO_NAME
