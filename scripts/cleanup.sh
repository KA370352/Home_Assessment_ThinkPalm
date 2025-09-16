#!/bin/bash

# Cleanup Script for Robot Framework Test Environment
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Cleaning up Robot Framework Test Environment${NC}"

# Function to stop and remove containers
cleanup_containers() {
    echo -e "${YELLOW}Stopping and removing containers...${NC}"
    docker-compose down -v --remove-orphans

    # Remove any dangling containers
    if [ "$(docker ps -aq -f status=exited)" ]; then
        docker rm $(docker ps -aq -f status=exited)
    fi
}

# Function to clean up volumes
cleanup_volumes() {
    echo -e "${YELLOW}Cleaning up Docker volumes...${NC}"
    docker volume prune -f
}

# Function to clean up networks
cleanup_networks() {
    echo -e "${YELLOW}Cleaning up Docker networks...${NC}"
    docker network prune -f
}

# Function to clean up reports
cleanup_reports() {
    echo -e "${YELLOW}Cleaning up test reports...${NC}"
    if [ -d "reports" ]; then
        rm -rf reports/*
        mkdir -p reports/allure-results reports/allure-reports
    fi

    if [ -d "data" ]; then
        rm -rf data/*
    fi

    if [ -d "logs" ]; then
        rm -rf logs/*
    fi
}

# Main cleanup function
main_cleanup() {
    cleanup_containers
    cleanup_volumes
    cleanup_networks
    cleanup_reports
}

# Parse command line arguments
case "${1:-all}" in
    "containers")
        cleanup_containers
        ;;
    "volumes")
        cleanup_volumes
        ;;
    "networks")
        cleanup_networks
        ;;
    "reports")
        cleanup_reports
        ;;
    "all")
        main_cleanup
        ;;
    *)
        echo -e "${RED}Usage: $0 [containers|volumes|networks|reports|all]${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}Cleanup completed!${NC}"
