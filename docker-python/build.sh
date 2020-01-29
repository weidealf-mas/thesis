#!/bin/bash

echo "building python base image"

# will run quit a long time!
cd ~/Development/workspaces/datascience/masterarbeit/docker-python
# docker build -t swisssign/python3-alpine10:pyarrow_0.14.1 .

# docker build -f Dockerfile_tf -t swisssign/python3-alpine10:tf_1.13.2_keras_2.2.5 .

echo "building spark images"
cd ~/Development/workspaces/datascience/masterarbeit/docker-spark/base
docker build -t bde2020/spark-base:2.4.4-hadoop2.7 .

cd ../master
docker build -t bde2020/spark-master:2.4.4-hadoop2.7 .

cd ../worker
docker build -t bde2020/spark-worker:2.4.4-hadoop2.7 .

cd ../submit
docker build -t bde2020/spark-submit:2.4.4-hadoop2.7 .

cd ../template/python
docker build -t bde2020/spark-python-template:2.4.4-hadoop2.7 .
