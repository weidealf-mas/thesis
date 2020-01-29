#!/bin/bash

rm -R ~/Development/workspaces/datascience/masterarbeit/shared/checkpoints

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  docker run --name anomaly-detector --rm -e ENABLE_INIT_DAEMON=false -p 4050:4040 --network=fdp-infrastructure_fdp-net \
           -v ~/Development/workspaces/datascience/masterarbeit/shared:/shared swisssign/anomaly-detector
else
  docker run --name anomaly-detector --rm -e ENABLE_INIT_DAEMON=false -p 4050:4040 --network=fdpinfrastructure_fdp-net \
           -v ~/Development/workspaces/datascience/masterarbeit/shared:/shared swisssign/anomaly-detector
fi
