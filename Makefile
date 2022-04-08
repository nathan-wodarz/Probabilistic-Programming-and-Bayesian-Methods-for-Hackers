NB_DOCKERFILE := Dockerfile.local
NB_NAME := tfp-tutorial
NB_PORT := 8675
DOCKER_ARGS := --build-arg USER_ID=$(shell id -u ${USER}) --build-arg GROUP_ID=$(shell id -g ${USER})
.DEFAULT_GOAL := help

.PHONY: help up down clean

help: Makefile
	@sed -n 's/^##//p' $< | cat

## up    | Build image, run notebook server container in background
up: down
	docker build . ${DOCKER_ARGS} -f ${NB_DOCKERFILE} -t ${NB_NAME} --pull
	docker run -d --restart always -p ${NB_PORT}:${NB_PORT} \
		-v ${PWD}/notebooks:/usr/src/app/notebooks \
		--name ${NB_NAME} ${NB_NAME}:latest \
		bash -c 'jupyter notebook --port=${NB_PORT} --ip=0.0.0.0 --NotebookApp.allow_origin='*' --NotebookApp.password="sha1:f217aa434731:b01a46c5ffccfc413ccffc33c802882737ac2ccd"'

## down  | Stop and remove notebook server container
down:
	docker stop ${NB_NAME} || true
	docker rm ${NB_NAME} || true

## clean | Run nbstripout on all notebooks
clean: down
	docker run -v ${PWD}:/usr/src/app/ --rm -it --name ${NB_NAME} ${NB_NAME}:latest bash run_nbstripout.sh || true