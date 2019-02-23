#!/bin/bash

echo "### stopping the webapi and dashboard services ..."
docker-compose stop webapi dashboard

echo "### getting the latest webapi and dashboard docker images ..."
docker-compose pull webapi dashboard

echo "### restarting the webapi and dashboard services ..."
docker-compose up -d