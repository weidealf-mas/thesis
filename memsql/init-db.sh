#!/bin/bash
export LICENSE_KEY=...

# On Mac OSX us this command
docker run -i --init --name memsql -e LICENSE_KEY=$LICENSE_KEY -p 3309:3306 -p 8089:8080 --network=fdp-infrastructure_fdp-net memsql/cluster-in-a-box

# On Ubuntu us this command (different network naming!)
#docker run -i --init --name memsql -e LICENSE_KEY=$LICENSE_KEY -p 3309:3306 -p 8089:8080 --network=fdpinfrastructure_fdp-net memsql/cluster-in-a-box
