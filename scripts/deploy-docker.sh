#!/usr/bin/env bash
# Docker Deployment Script for The Roofing App
# Usage: ./scripts/deploy-docker.sh [build|run|push|deploy]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="paulroofs-app"
IMAGE_TAG="latest"
CONTAINER_NAME="paulroofs-app"
HOST_PORT="80"
CONTAINER_PORT="80"
REGISTRY_URL="" # Set this if using a registry (e.g., ghcr.io/yourusername/paulroofs-app)

# Default action
ACTION=${1:-build}

echo -e "${BLUE}🐳 Docker Deployment Script${NC}"
echo -e "${BLUE}Action: ${ACTION}${NC}"
echo

case $ACTION in
    "build")
        echo -e "${YELLOW}🔨 Building Docker image...${NC}"
        
        # Check if .env file exists
        if [ ! -f ".env" ]; then
            echo -e "${YELLOW}⚠️  No .env file found${NC}"
            echo "Copy .env.example to .env and fill in your Supabase credentials"
            echo "Docker will build without environment variables (they're read at build time)"
            echo
        fi
        
        # Build the image
        docker build -t $IMAGE_NAME:$IMAGE_TAG . || {
            echo -e "${RED}❌ Docker build failed${NC}"
            exit 1
        }
        
        echo -e "${GREEN}✅ Docker image built successfully${NC}"
        echo -e "${BLUE}📊 Image size:${NC}"
        docker images $IMAGE_NAME:$IMAGE_TAG --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
        ;;
        
    "run")
        echo -e "${YELLOW}🚀 Running Docker container...${NC}"
        
        # Stop and remove existing container if it exists
        if docker ps -a --format 'table {{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
            echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
            docker stop $CONTAINER_NAME || true
            docker rm $CONTAINER_NAME || true
        fi
        
        # Run the container
        docker run -d \
            --name $CONTAINER_NAME \
            -p $HOST_PORT:$CONTAINER_PORT \
            --restart unless-stopped \
            $IMAGE_NAME:$IMAGE_TAG || {
            echo -e "${RED}❌ Failed to start container${NC}"
            exit 1
        }
        
        echo -e "${GREEN}✅ Container started successfully${NC}"
        echo -e "${BLUE}🌐 App should be available at: http://localhost:$HOST_PORT${NC}"
        echo
        echo -e "${YELLOW}📊 Container status:${NC}"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
        
    "push")
        if [ -z "$REGISTRY_URL" ]; then
            echo -e "${RED}❌ REGISTRY_URL not configured${NC}"
            echo "Set REGISTRY_URL in this script to push to a registry"
            exit 1
        fi
        
        echo -e "${YELLOW}📤 Pushing to registry...${NC}"
        
        # Tag for registry
        docker tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY_URL:$IMAGE_TAG
        
        # Push to registry
        docker push $REGISTRY_URL:$IMAGE_TAG || {
            echo -e "${RED}❌ Failed to push to registry${NC}"
            exit 1
        }
        
        echo -e "${GREEN}✅ Image pushed successfully${NC}"
        echo -e "${BLUE}📦 Registry URL: $REGISTRY_URL:$IMAGE_TAG${NC}"
        ;;
        
    "deploy")
        echo -e "${YELLOW}🚀 Full deployment (build + run)...${NC}"
        
        # Build first
        $0 build
        
        # Then run
        $0 run
        
        echo -e "${GREEN}🎉 Deployment complete!${NC}"
        ;;
        
    "stop")
        echo -e "${YELLOW}🛑 Stopping container...${NC}"
        docker stop $CONTAINER_NAME || {
            echo -e "${RED}❌ Failed to stop container (may not be running)${NC}"
        }
        docker rm $CONTAINER_NAME || true
        echo -e "${GREEN}✅ Container stopped and removed${NC}"
        ;;
        
    "logs")
        echo -e "${YELLOW}📋 Container logs:${NC}"
        docker logs $CONTAINER_NAME --tail 50 -f
        ;;
        
    "shell")
        echo -e "${YELLOW}💻 Opening shell in container...${NC}"
        docker exec -it $CONTAINER_NAME /bin/bash || {
            echo -e "${RED}❌ Failed to open shell (container may not be running)${NC}"
            exit 1
        }
        ;;
        
    "status")
        echo -e "${YELLOW}📊 Container status:${NC}"
        if docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "$CONTAINER_NAME"; then
            docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            echo
            echo -e "${GREEN}✅ Container is running${NC}"
            echo -e "${BLUE}🌐 App available at: http://localhost:$HOST_PORT${NC}"
        else
            echo -e "${RED}❌ Container is not running${NC}"
        fi
        ;;
        
    "clean")
        echo -e "${YELLOW}🧹 Cleaning up Docker resources...${NC}"
        
        # Stop and remove container
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        
        # Remove image
        docker rmi $IMAGE_NAME:$IMAGE_TAG 2>/dev/null || true
        
        # Clean up build cache
        docker builder prune -f
        
        echo -e "${GREEN}✅ Cleanup complete${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ Unknown action: $ACTION${NC}"
        echo
        echo -e "${YELLOW}Available actions:${NC}"
        echo "  build   - Build Docker image"
        echo "  run     - Run container (stops existing first)"
        echo "  push    - Push image to registry (configure REGISTRY_URL first)"
        echo "  deploy  - Full deployment (build + run)"
        echo "  stop    - Stop and remove container"
        echo "  logs    - Show container logs"
        echo "  shell   - Open shell in running container"
        echo "  status  - Show container status"
        echo "  clean   - Clean up all Docker resources"
        echo
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 build"
        echo "  $0 deploy"
        echo "  $0 status"
        exit 1
        ;;
esac

echo