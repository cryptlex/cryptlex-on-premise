#!/bin/bash

echo "### getting the latest docker images ..."
docker compose pull reverse-proxy cache web-api admin-portal customer-portal reseller-portal release-server

echo "### restarting the updated services ..."
docker compose up -d
