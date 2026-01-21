#!/bin/bash

echo "Stopping old containers and removing volumes/networks..."
docker-compose down -v

echo "Pruning unused networks to ensure clean state..."
docker network prune -f

echo "Building and starting new container..."
docker-compose up -d --build

echo "Done! Container status:"
docker ps

echo "Network info:"
docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" ip_checker_site
