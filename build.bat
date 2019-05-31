@echo off

set DOCKER_REPO=remigius65
set IMAGE_NAME=pg-dump
set VERSION=0.0.4

@FOR /f %%i IN ('git rev-parse --short HEAD') DO SET GIT_COMMIT_HASH=%%i

set DOCKER_VERSION_TAG=%IMAGE_NAME%:%VERSION%-%GIT_COMMIT_HASH%
set DOCKER_LATEST_TAG=%IMAGE_NAME%:latest
set DOCKER_REPO_VERSION_TAG=%DOCKER_REPO%/%DOCKER_VERSION_TAG%
set DOCKER_REPO_LATEST_TAG=%DOCKER_REPO%/%DOCKER_LATEST_TAG%

rem @FOR /f "tokens=*" %%i IN ('docker-machine env default --no-proxy') DO @%%i

echo build docker image with tags: %DOCKER_VERSION_TAG%, %DOCKER_LATEST_TAG%, %DOCKER_REPO_VERSION_TAG%, %DOCKER_REPO_LATEST_TAG%

docker build --build-arg http_proxy=http://10.200.4.1:3128/ --build-arg https_proxy=http://10.200.4.1:3128/ -t %DOCKER_VERSION_TAG% -t %DOCKER_LATEST_TAG% -t %DOCKER_REPO_VERSION_TAG% -t %DOCKER_REPO_LATEST_TAG% .

rem echo and now push it...

docker push %DOCKER_REPO_VERSION_TAG%
docker push %DOCKER_REPO_LATEST_TAG%

echo done
