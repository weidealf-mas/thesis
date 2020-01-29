#!/bin/bash

cd ~/Development/workspaces/datascience/masterarbeit/anomaly-detector

rm -R ./target
mkdir target

cp Dockerfile ./target
cp *.py ./target
cp requirements.txt ./target

mkdir ./target/ml_utils
cp ../ml_utils/*.py ./target/ml_utils

img_id=$(docker images -q swisssign/anomaly-detector)

if [ -z "$img_id" ]
then
      echo "nothing to delete"
else
      echo "removing the image"
      docker rmi $img_id
fi

cd ./target
docker build --rm -t swisssign/anomaly-detector .
cd ..
