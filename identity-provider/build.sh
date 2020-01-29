#!/bin/bash

cd ~/Development/workspaces/datascience/masterarbeit/identity-provider

img_id=$(docker images -q swisssign/identity-provider)

if [ -z "$img_id" ]
then
      echo "nothing to delete"
else
      echo "removing the image"
      docker rmi $img_id
fi

docker build --rm -t swisssign/identity-provider .
