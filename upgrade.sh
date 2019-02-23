#!/bin/bash

echo "### stopping the Cryptlex services ..."
docker-compose stop

echo "### getting the latest webapi and dashboard docker images ..."
docker-compose pull webapi dashboard

echo "### starting the Cryptlex services ..."
docker-compose up -d