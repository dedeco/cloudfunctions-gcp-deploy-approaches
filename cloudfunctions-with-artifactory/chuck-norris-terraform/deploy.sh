#!/bin/bash

# Script to deploy the Chuck Norris Jokes function using Terraform

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if required commands are available
command -v gcloud >/dev/null 2>&1 || { echo -e "${RED}Google Cloud SDK (gcloud) is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform is required but not installed. Aborting.${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed. Aborting.${NC}" >&2; exit 1; }

# Check if project ID is provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 <project-id> [region] [function-name]${NC}"
    echo -e "Example: $0 my-gcp-project us-central1 chuck-norris-jokes"
    exit 1
fi

PROJECT_ID=$1
REGION=${2:-"us-central1"} # Default to us-central1 if no region specified
FUNCTION_NAME=${3:-"chuck-norris-jokes"} # Default function name

echo -e "${GREEN}Deploying Chuck Norris Jokes Cloud Function...${NC}"
echo -e "${GREEN}Project ID: ${PROJECT_ID}${NC}"
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
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com storage.googleapis.com artifactregistry.googleapis.com run.googleapis.com

# Create Artifact Registry repository if it doesn't exist
REPO_NAME="cloud-functions"
echo -e "${GREEN}Creating Artifact Registry repository if it doesn't exist...${NC}"
if ! gcloud artifacts repositories describe "$REPO_NAME" --location="$REGION" &>/dev/null; then
    echo -e "${GREEN}Creating repository: ${REPO_NAME} in ${REGION}${NC}"
    gcloud artifacts repositories create "$REPO_NAME" \
        --repository-format=docker \
        --location="$REGION" \
        --description="Repository for Cloud Functions containers"
else
    echo -e "${YELLOW}Repository ${REPO_NAME} already exists in ${REGION}${NC}"
fi

# Configure Docker to use gcloud as a credential helper for Artifact Registry
echo -e "${GREEN}Configuring Docker authentication...${NC}"
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Update terraform.tfvars
echo -e "${GREEN}Updating terraform.tfvars with your project information...${NC}"
cat > terraform.tfvars << EOF2
project_id    = "${PROJECT_ID}"
region        = "${REGION}"
function_name = "${FUNCTION_NAME}"
EOF2

# Initialize Terraform
echo -e "${GREEN}Initializing Terraform...${NC}"
terraform init

# Plan the deployment
echo -e "${GREEN}Planning Terraform deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo
echo -e "${YELLOW}Ready to deploy the Chuck Norris jokes Cloud Function to project: ${PROJECT_ID}${NC}"
read -p "Do you want to continue with the deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 1
fi

# Apply the Terraform plan
echo -e "${GREEN}Deploying infrastructure...${NC}"
terraform apply tfplan

# Get and display the function URL
FUNCTION_URL=$(terraform output -raw function_url)
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}Function URL: ${FUNCTION_URL}${NC}"
echo
echo -e "${YELLOW}Testing the function...${NC}"
curl -s "$FUNCTION_URL"

echo
echo -e "${GREEN}To test the function again, run:${NC}"
echo -e "curl ${FUNCTION_URL}"
