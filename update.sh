#!/bin/bash

echo "### getting the latest web-api, dashboard and release-server docker images ..."
docker-compose pull web-api dashboard release-server

echo "### stopping the web-api, dashboard and release-server services ..."
docker-compose stop web-api dashboard release-server

echo "### restarting the web-api, dashboard and release-server services ..."
docker-compose up -d