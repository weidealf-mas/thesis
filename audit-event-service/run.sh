#!/bin/bash

docker run --name audit-event-service --rm -p 5051:8080 --network=fdp-infrastructure_fdp-net swisssign/audit-event-service

#docker run --name audit-event-service --rm -p 5051:8080 --network=fdpinfrastructure_fdp-net swisssign/audit-event-service