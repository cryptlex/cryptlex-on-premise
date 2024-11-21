#!/bin/bash

echo "### getting the latest docker images ..."
docker compose pull web-api dashboard admin-portal customer-portal reseller-portal release-server

echo "### stopping the services ..."
docker compose stop web-api dashboard admin-portal customer-portal reseller-portal release-server

echo "### restarting the services ..."
docker compose up -d
