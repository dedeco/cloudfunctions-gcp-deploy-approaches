# Chuck Norris Jokes Cloud Function with Terraform

This project uses Terraform to deploy a Google Cloud Function that serves random Chuck Norris jokes. The deployment process includes:

1. Creating an Artifact Registry repository
2. Generating the function code locally
3. Building a Docker container
4. Pushing the container to Artifact Registry
5. Deploying the Cloud Function using the container

## Prerequisites

- Google Cloud Platform account
- Google Cloud SDK (gcloud) installed and configured
- Docker installed
- Terraform installed

## Deployment

You can deploy the function in two ways:

### Option 1: Using the deployment script

The easiest way is to use the provided script:

```bash
chmod +x deploy.sh
./deploy.sh your-project-id [region] [function-name]
```

For example:
```bash
./deploy.sh my-gcp-project us-central1 chuck-norris-jokes
```

### Option 2: Manual Terraform deployment

1. Update `terraform.tfvars` with your project information:

   ```
   project_id    = "your-project-id"
   region        = "us-central1"
   function_name = "chuck-norris-jokes"
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Apply the configuration:

   ```bash
   terraform apply
   ```

## What's Happening Behind the Scenes

The Terraform configuration:

1. Creates an Artifact Registry repository called "cloud-functions"
2. Generates the function code files locally
3. Builds a Docker container with the function code
4. Pushes the container to Artifact Registry
5. Creates a Cloud Storage bucket for temporary storage
6. Deploys a Cloud Function (2nd gen) that uses the container
7. Configures public access to the function

## Testing the Function

After deployment, you can test the function with:

```bash
curl $(terraform output -raw function_url)
```

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Files

- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `terraform.tfvars`: Variable values (customize this)
- `deploy.sh`: Deployment script
