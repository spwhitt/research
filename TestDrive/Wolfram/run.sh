#!/bin/sh

# Runs a jupyter lab notebook with connection to WolframEngine

docker run --rm -p 8888:8888 \
  -v "${PWD}"/work:/home/jovyan/work \
  -v "${PWD}"/license:/usr/local/Wolfram/WolframEngine/12.1/Configuration/Licensing \
  jupyter-mathematica
