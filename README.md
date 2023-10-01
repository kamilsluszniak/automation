# README

# Docker JFrog login:

`docker login easyautomateme.jfrog.io`

# Building and pushing:

docker build -f Dockerfile.worker -t worker:latest .
docker tag worker:latest easyautomateme.jfrog.io/easyautomateme-docker/worker:latest
docker push easyautomateme.jfrog.io/easyautomateme-docker/worker:latest

docker build -f Dockerfile.api -t api:latest .
docker tag api:latest easyautomateme.jfrog.io/easyautomateme-docker/api:latest
docker push easyautomateme.jfrog.io/easyautomateme-docker/api:latest