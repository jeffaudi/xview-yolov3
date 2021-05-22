#!/usr/bin/env bash
BUILD=false
INTER=false
GPU=true
IMAGE=xview-yolov3
CODE_DIR=$PWD
DATA_DIR=/home/jean_francois_faudi/data
#DATA_DIR=/home/jeff/Data/

for i in "$@"
do
  case $i in
    -b|--build)
    BUILD=true
    ;;
    -g|--gpu)
    GPU=true
    ;;
    -c|--cpu)
    GPU=false
    ;;
    -i|--interactive)
    INTER=true
    ;;
  esac
done

if [[ "${BUILD}" = true ]]
then
  echo "Building Docker container..."
  docker build -f Dockerfile -t ${IMAGE} \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) .
fi

GPU_FLAG=""
if [[ "${GPU}" = true ]]
then
  GPU_FLAG="--gpus all" 
fi

if [[ "${INTER}" = false ]]
then
  echo "Launching Jupyter Notebook..."
  docker run ${GPU_FLAG} --rm \
    --privileged \
    --shm-size 64G \
    --volume ${CODE_DIR}:/home/jovyan/code/ \
    --volume ${DATA_DIR}:/data/ \
    --workdir /home/jovyan/code/ \
    -p 8080:8080 \
    -p 8443:6006 \
    ${IMAGE}
else
  echo "Entering interactive mode..."
  docker run ${GPU_FLAG} --rm -it \
    --privileged \
    --shm-size 64G \
    --volume ${CODE_DIR}:/home/jovyan/code/ \
    --volume ${DATA_DIR}:/data/ \
    --workdir /home/jovyan/code/ \
    --entrypoint /bin/bash \
    -p 8080:8080 \
    -p 8443:6006 \
    ${IMAGE} -i
fi
