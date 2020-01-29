#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  docker run --name identity-provider --rm -p 5050:8080 --network=fdp-infrastructure_fdp-net \
           -v ~/Development/workspaces/datascience/masterarbeit/shared:/shared swisssign/identity-provider
else
  docker run --name identity-provider --rm -p 5050:8080 --network=fdpinfrastructure_fdp-net \
          -v ~/Development/workspaces/datascience/masterarbeit/shared:/shared swisssign/identity-provider
fi