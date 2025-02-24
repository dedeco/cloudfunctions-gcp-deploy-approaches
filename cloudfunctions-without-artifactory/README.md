# Chuck Norris Jokes Cloud Function

This Terraform configuration deploys a simple Google Cloud Function that serves random Chuck Norris jokes via an HTTP endpoint.

## Prerequisites

- Google Cloud Platform account
- Google Cloud CLI installed and configured
- Terraform installed
- A Google Cloud project with the following APIs enabled:
  - Cloud Functions API
  - Cloud Build API
  - Cloud Storage API
  - IAM API

## Files

- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `terraform.tfvars`: Variable values (customize this)
- `function-source/`: Directory containing the Cloud Function source code
  - `index.js`: JavaScript code for the Cloud Function
  - `package.json`: Node.js package definition

## Deployment Steps

1. Update the `terraform.tfvars` file with your Google Cloud project ID:

   ```
   project_id = "your-project-id"
   region     = "us-central1"  # Change if needed
   ```

2. Initialize Terraform:

   ```
   terraform init
   ```

3. Plan the deployment:

   ```
   terraform plan
   ```

4. Apply the configuration:

   ```
   terraform apply
   ```

5. After deployment, Terraform will output the URL of your Cloud Function. You can test it by visiting this URL in a browser or using curl:

   ```
   curl $(terraform output -raw function_url)
   ```

## Cleanup

To remove all resources created by this configuration:

```
terraform destroy
```

## Customization

- To add more jokes, edit the `jokes` array in the `function-source/index.js` file.
- To change the function's memory allocation, modify the `available_memory_mb` parameter in `main.tf`.
- For a different runtime (Python, Go, etc.), change the `runtime` parameter and update the function code accordingly.
