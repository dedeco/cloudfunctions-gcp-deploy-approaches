
# Sample Cloud Function: Deployment Options

This repository demonstrates three different approaches to deploy a Chuck Norris jokes API as a Google Cloud Function:

1. **No Terraform**: Direct deployment using gcloud CLI
2. **With Artifactory**: Using Terraform to build and push a container to Artifact Registry, then deploy as a Cloud Function
3. **Without Artifactory**: Using Terraform to deploy directly from source code

Each approach has its own advantages and use cases. Choose the one that best fits your requirements.

## Project Structure

```
├── cloudfunctions-no-terraform
│   ├── chuck-norris-function
│   │   ├── command.txt
│   │   ├── index.js
│   │   ├── package.json
│   │   └── README.md
│   └── deploy-function.sh
├── cloudfunctions-with-artifactory
│   └── chuck-norris-terraform
│       ├── function-source
│       │   ├── Dockerfile
│       │   ├── index.js
│       │   └── package.json
│       ├── function-source.zip
│       ├── main.tf
│       ├── terraform.tfstate
│       ├── terraform.tfstate.backup
│       ├── terraform.tfvars
│       └── variables.tf
├── cloudfunctions-without-artifactory
│   ├── function-source
│   │   ├── index.js
│   │   └── package.json
│   ├── function-source.zip
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
```

## Approach 1: No Terraform (gcloud CLI)

This is the simplest approach using just the `gcloud` command-line tool to deploy the function directly from source code.

### Prerequisites
- Google Cloud SDK (gcloud) installed and configured
- Node.js and npm (for local development/testing)

### Deployment

Navigate to the function directory:
```bash
cd cloudfunctions-no-terraform/chuck-norris-function
```

Deploy the function using gcloud CLI:
```bash
gcloud functions deploy "chuck-norris-jokes-demo-1" \
  --region=us-central1 \
  --runtime=nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=getRandomJoke \
  --timeout=60s \
  --set-env-vars=NODE_ENV=production
```

### Advantages
- Simple and straightforward
- No additional tools required beyond gcloud
- Quick for small functions and prototyping

### Limitations
- Limited infrastructure as code capabilities
- Manual process that's harder to version and automate
- Less suitable for complex deployments

## Approach 2: Terraform with Artifact Registry

This approach uses Terraform to:
1. Generate the function code
2. Build a Docker container with the function
3. Push the container to Google Artifact Registry
4. Deploy the container as a Cloud Function

### Prerequisites
- Google Cloud SDK (gcloud) installed and configured
- Terraform installed
- Docker installed and running

### Deployment

Navigate to the terraform directory:
```bash
cd cloudfunctions-with-artifactory/chuck-norris-terraform
```

Update project_id in terraform.tfvars:
```
project_id    = "your-project-id"  # Replace with your actual GCP project ID
region        = "us-central1"      # Change if needed
function_name = "chuck-norris-jokes"
```

Initialize and apply the Terraform configuration:
```bash
terraform init
terraform apply
```

### What happens behind the scenes
1. Creates an Artifact Registry repository called "cloud-functions"
2. Generates the function code files locally
3. Builds a Docker container with the function code
4. Pushes the container to Artifact Registry
5. Creates a Cloud Storage bucket for temporary storage
6. Deploys a Cloud Function (2nd gen) using the container
7. Configures public access to the function

### Advantages
- Full infrastructure as code
- Container-based approach for more complex dependencies
- Better control over the runtime environment
- Suitable for enterprise deployments and CI/CD pipelines
- Reproducible and version-controlled deployments

### Limitations
- More complex setup
- Requires Docker
- Slightly longer deployment time

## Approach 3: Terraform without Artifact Registry

This approach uses Terraform to deploy the function directly from source code, without building or using containers.

### Prerequisites
- Google Cloud SDK (gcloud) installed and configured
- Terraform installed

### Deployment

Navigate to the terraform directory:
```bash
cd cloudfunctions-without-artifactory
```

Update project_id in terraform.tfvars:
```
project_id    = "your-project-id"  # Replace with your actual GCP project ID
region        = "us-central1"      # Change if needed
function_name = "chuck-norris-jokes"
```

Initialize and apply the Terraform configuration:
```bash
terraform init
terraform apply
```

### What happens behind the scenes
1. Creates a Cloud Storage bucket for the function source code
2. Zips and uploads the function source code to the bucket
3. Deploys a Cloud Function (1st gen) using the source code
4. Configures public access to the function

### Advantages
- Infrastructure as code without container complexity
- Faster deployment than the container approach
- No Docker dependency
- Good balance of simplicity and automation

### Limitations
- Less control over the runtime environment
- More difficult to include complex dependencies

## Which Approach Should You Choose?

- **Approach 1 (No Terraform)**: Use for quick prototypes, simple functions, or if you're new to GCP
- **Approach 2 (With Artifactory)**: Use for production deployments, when you need custom libraries or dependencies, or for complex enterprise scenarios
- **Approach 3 (Without Artifactory)**: Use for simpler production deployments when you want infrastructure as code but don't need container customization

## Testing Your Function

After deployment, you can test your function with:

```bash
# For the gcloud deployment approach
curl https://REGION-PROJECT_ID.cloudfunctions.net/FUNCTION_NAME

# For the Terraform approaches
curl $(terraform output -raw function_url)
```

You should receive a random Chuck Norris joke in JSON format.

## Cleanup

To remove all resources created by Terraform:

```bash
terraform destroy
```

For the gcloud deployment, delete the function with:

```bash
gcloud functions delete chuck-norris-jokes-demo-1 --region=us-central1
```

## Notes

When you deploy your function's source code to Cloud Run functions, that source is stored in a Cloud Storage bucket. Cloud Build then automatically builds your code into a container image and pushes that image to an image registry. Cloud Run functions accesses this image when it needs to run the container to execute your function. 


[Documentation](https://cloud.google.com/functions/docs/building)
