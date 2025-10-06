#!/bin/bash

# Deployment script for POC HTML App to Google Cloud Run
# Make sure to set your PROJECT_ID before running this script

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-your-project-id-here}"
SERVICE_NAME="poc-html-app"
REGION="us-central1"
GAR_LOCATION="us-central1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting deployment of POC HTML App...${NC}"

# Check if PROJECT_ID is set
if [ "$PROJECT_ID" = "your-project-id-here" ]; then
    echo -e "${RED}Error: Please set your PROJECT_ID environment variable${NC}"
    echo "Example: export PROJECT_ID=my-gcp-project"
    exit 1
fi

echo -e "${GREEN}Using Project ID: $PROJECT_ID${NC}"

# Set the current project
gcloud config set project $PROJECT_ID

# Build and tag the Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t $SERVICE_NAME .

# Tag for Artifact Registry
IMAGE_URL="$GAR_LOCATION-docker.pkg.dev/$PROJECT_ID/$SERVICE_NAME/$SERVICE_NAME:latest"
docker tag $SERVICE_NAME $IMAGE_URL

# Push to Artifact Registry
echo -e "${YELLOW}Pushing image to Artifact Registry...${NC}"
docker push $IMAGE_URL

# Deploy to Cloud Run
echo -e "${YELLOW}Deploying to Cloud Run...${NC}"
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_URL \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --platform managed

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}Service URL: $SERVICE_URL${NC}"
echo -e "${GREEN}Health Check: $SERVICE_URL/health${NC}"