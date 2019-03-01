#!/bin/bash

echo "### getting the latest webapi, dashboard and release-server docker images ..."
docker-compose pull webapi dashboard release-server

echo "### stopping the webapi, dashboard and release-server services ..."
docker-compose stop webapi dashboard release-server

echo "### restarting the webapi, dashboard and release-server services ..."
docker-compose up -d