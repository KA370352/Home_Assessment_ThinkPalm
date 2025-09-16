#!/bin/bash

# Environment Setup Script for Robot Framework Testing
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up Robot Framework Test Environment${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists docker; then
    echo -e "${RED}Docker is required but not installed.${NC}"
    exit 1
fi

if ! command_exists docker-compose; then
    echo -e "${RED}Docker Compose is required but not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites check passed!${NC}"

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p reports/allure-results
mkdir -p reports/allure-reports
mkdir -p data
mkdir -p logs

# Set execute permissions
chmod +x scripts/*.sh

# Pull Docker images
echo -e "${YELLOW}Pulling Docker images...${NC}"
docker-compose pull

# Start infrastructure services
echo -e "${YELLOW}Starting infrastructure services...${NC}"
docker-compose up -d kafka zookeeper rabbitmq prometheus pushgateway grafana allure

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 60

# Check service health
echo -e "${YELLOW}Checking service health...${NC}"

services=("kafka:9092" "rabbitmq:15672" "prometheus:9090" "grafana:3000")
for service in "${services[@]}"; do
    if docker-compose exec ${service%%:*} echo "Service is running" 2>/dev/null; then
        echo -e "${GREEN}✓ ${service} is ready${NC}"
    else
        echo -e "${RED}✗ ${service} is not ready${NC}"
    fi
done

# Display service URLs
echo -e "${BLUE}Service URLs:${NC}"
echo -e "  - Grafana Dashboard: ${GREEN}http://localhost:3000${NC} (admin/admin)"
echo -e "  - Prometheus: ${GREEN}http://localhost:9090${NC}"
echo -e "  - RabbitMQ Management: ${GREEN}http://localhost:15672${NC} (guest/guest)"
echo -e "  - Allure Reports: ${GREEN}http://localhost:5050${NC}"

echo -e "${GREEN}Environment setup completed!${NC}"
echo -e "${YELLOW}Run './scripts/run_tests.sh' to execute tests${NC}"
