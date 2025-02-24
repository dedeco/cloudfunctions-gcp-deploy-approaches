#!/bin/bash

# Script to deploy a Chuck Norris jokes Cloud Function using gcloud CLI
# This deploys existing files to Google Cloud

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if gcloud is installed
command -v gcloud >/dev/null 2>&1 || { echo -e "${RED}Google Cloud SDK (gcloud) is required but not installed. Aborting.${NC}" >&2; exit 1; }

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo -e "${YELLOW}Usage: $0 <project-id> <source-dir> [region] [function-name]${NC}"
    echo -e "Example: $0 my-gcp-project ./chuck-norris-function us-central1 chuck-norris-jokes"
    exit 1
fi

PROJECT_ID=$1
SOURCE_DIR=$2
REGION=${3:-"us-central1"} # Default to us-central1 if no region specified
FUNCTION_NAME=${4:-"chuck-norris-jokes"} # Default function name

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Source directory doesn't exist: ${SOURCE_DIR}${NC}"
    echo -e "${YELLOW}Generate the files first using generate-files.sh${NC}"
    exit 1
fi

# Check if the required files exist
if [ ! -f "${SOURCE_DIR}/index.js" ] || [ ! -f "${SOURCE_DIR}/package.json" ]; then
    echo -e "${RED}Required files (index.js and/or package.json) not found in: ${SOURCE_DIR}${NC}"
    exit 1
fi

echo -e "${GREEN}Deploying Chuck Norris Jokes Cloud Function...${NC}"
echo -e "${GREEN}Project ID: ${PROJECT_ID}${NC}"
echo -e "${GREEN}Source Directory: ${SOURCE_DIR}${NC}"
echo -e "${GREEN}Region: ${REGION}${NC}"
echo -e "${GREEN}Function Name: ${FUNCTION_NAME}${NC}"

# Check if already authenticated with gcloud
if ! gcloud auth print-access-token &>/dev/null; then
    echo -e "${YELLOW}You need to authenticate with Google Cloud...${NC}"
    gcloud auth login
fi

# Set the correct project
echo -e "${GREEN}Setting Google Cloud project to: ${PROJECT_ID}${NC}"
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo -e "${GREEN}Enabling required Google Cloud APIs...${NC}"
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com

# Change to the source directory
cd "$SOURCE_DIR"

# Deploy the function
echo -e "${GREEN}Deploying the Cloud Function...${NC}"
gcloud functions deploy "$FUNCTION_NAME" \
  --region="$REGION" \
  --runtime=nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=getRandomJoke \
  --timeout=60s \
  --set-env-vars=NODE_ENV=production

# Get the deployed function URL
FUNCTION_URL=$(gcloud functions describe "$FUNCTION_NAME" --region="$REGION" --format="value(httpsTrigger.url)")

echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Function URL: ${FUNCTION_URL}${NC}"
echo
echo -e "${YELLOW}Testing the function...${NC}"
curl -s "$FUNCTION_URL"

echo
echo -e "${GREEN}To test the function again, run:${NC}"
echo -e "curl ${FUNCTION_URL}"