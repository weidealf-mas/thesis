#!/bin/bash

cd ~/Development/workspaces/datascience/masterarbeit/audit-event-service

img_id=$(docker images -q swisssign/audit-event-service)

if [ -z "$img_id" ]
then
      echo "nothing to delete"
else
      echo "removing the image"
      docker rmi $img_id
fi

docker build --rm -t swisssign/audit-event-service .
