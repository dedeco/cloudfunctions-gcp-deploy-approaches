provider "google" {
  project = var.project_id
  region  = var.region
}

# Create Artifact Registry Repository
resource "google_artifact_registry_repository" "function_repo" {
  location      = var.region
  repository_id = "cloud-functions-eneva"
  description   = "Docker repository for Cloud Functions"
  format        = "DOCKER"
}

# Create a Cloud Storage bucket for temporary files
resource "google_storage_bucket" "temp_bucket" {
  name     = "${var.project_id}-function-temp"
  location = var.region
  uniform_bucket_level_access = true
}

# Generate a unique ID for our function
resource "random_id" "function_id" {
  byte_length = 4
}

# Local files for our function code
resource "local_file" "function_index" {
  filename = "${path.module}/function-source/index.js"
  content  = <<-EOT
/**
 * Cloud Function that returns a random Chuck Norris joke
 * 
 * @param {Object} req Cloud Function request context
 * @param {Object} res Cloud Function response context
 */
exports.getRandomJoke = (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    // Handle preflight requests
    res.set('Access-Control-Allow-Methods', 'GET');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    res.status(204).send('');
    return;
  }
  
  // Array of Chuck Norris jokes
  const jokes = [
    "Chuck Norris doesn't read books. He stares them down until he gets the information he wants.",
    "Time waits for no man. Unless that man is Chuck Norris.",
    "If you spell Chuck Norris in Scrabble, you win. Forever.",
    "Chuck Norris can divide by zero.",
    "When Chuck Norris does a pushup, he isn't lifting himself up, he's pushing the Earth down.",
    "Chuck Norris is the reason why Waldo is hiding.",
    "Chuck Norris counted to infinity... twice.",
    "Chuck Norris doesn't wear a watch. HE decides what time it is.",
    "Chuck Norris can slam a revolving door.",
    "Chuck Norris doesn't call the wrong number. You answer the wrong phone.",
    "Chuck Norris can delete the Recycling Bin.",
    "Chuck Norris can win a game of Connect Four in only three moves.",
    "When the Boogeyman goes to sleep every night, he checks his closet for Chuck Norris.",
    "Chuck Norris once kicked a horse in the chin. Its descendants are now called giraffes."
  ];
  
  // Get a random joke
  const randomJoke = jokes[Math.floor(Math.random() * jokes.length)];
  
  // Send the joke
  res.status(200).json({
    joke: randomJoke
  });
};
  EOT

  # Create directory if it doesn't exist
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/function-source"
  }
}

resource "local_file" "function_package_json" {
  filename = "${path.module}/function-source/package.json"
  content  = <<-EOT
{
  "name": "chuck-norris-jokes",
  "version": "1.0.0",
  "description": "A Cloud Function that returns random Chuck Norris jokes",
  "main": "index.js",
  "engines": {
    "node": ">=20.0.0"
  },
  "dependencies": {},
  "private": true
}
  EOT

  depends_on = [local_file.function_index]
}

resource "local_file" "dockerfile" {
  filename = "${path.module}/function-source/Dockerfile"
  content  = <<-EOT
FROM node:20-slim

WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy function code
COPY . .

# Configure the container
ENV NODE_ENV production
ENV PORT 8080

# Run the web service on container startup
CMD [ "node", "-e", "const http = require('http'); const { getRandomJoke } = require('./index'); const server = http.createServer((req, res) => { getRandomJoke(req, res); }); server.listen(process.env.PORT);" ]
  EOT

  depends_on = [local_file.function_package_json]
}

# Build and push the container image
resource "null_resource" "docker_build_push" {
  triggers = {
    function_code_change = local_file.function_index.content
    dockerfile_change    = local_file.dockerfile.content
    package_json_change  = local_file.function_package_json.content
    random_id            = random_id.function_id.hex
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Configure Docker to use gcloud credentials
      gcloud auth configure-docker ${var.region}-docker.pkg.dev --quiet
      
      # Build the Docker image
      docker build -t ${var.region}-docker.pkg.dev/${var.project_id}/cloud-functions/chuck-norris-jokes:${random_id.function_id.hex} ./function-source
      
      # Push the image to Artifact Registry
      docker push ${var.region}-docker.pkg.dev/${var.project_id}/cloud-functions/chuck-norris-jokes:${random_id.function_id.hex}
    EOT
  }

  depends_on = [
    google_artifact_registry_repository.function_repo,
    local_file.dockerfile,
    local_file.function_index,
    local_file.function_package_json
  ]
}

# Deploy Cloud Function using the container image
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = "Cloud Function that returns random Chuck Norris jokes"

  build_config {
    runtime     = "nodejs20"
    entry_point = "getRandomJoke"
    
    source {
      storage_source {
        bucket = google_storage_bucket.temp_bucket.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      NODE_ENV = "production"
    }
    ingress_settings = "ALLOW_ALL"
  }

  depends_on = [null_resource.docker_build_push]
}

# Create a zip file of our function source
data "archive_file" "function_source" {
  type        = "zip"
  output_path = "${path.module}/function-source.zip"
  source_dir  = "${path.module}/function-source"
  
  depends_on = [
    local_file.function_index,
    local_file.function_package_json,
    local_file.dockerfile
  ]
}

# Upload the source code to the bucket
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.temp_bucket.name
  source = data.archive_file.function_source.output_path
}

# IAM entry to make the function publicly accessible
resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Output the URL of the deployed function
output "function_url" {
  value = google_cloudfunctions2_function.function.url
}

# Output the container image URL
output "container_image" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/cloud-functions/chuck-norris-jokes:${random_id.function_id.hex}"
}
