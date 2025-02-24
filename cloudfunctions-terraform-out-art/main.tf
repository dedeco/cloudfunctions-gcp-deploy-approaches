provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Cloud Storage bucket for storing the function source code
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-bucket"
  location = var.region
  uniform_bucket_level_access = true
}

# Archive the function source code
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/function-source"
  output_path = "${path.module}/function-source.zip"
}

# Upload the source code to the bucket
resource "google_storage_bucket_object" "function_code" {
  name   = "function-source-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.source.output_path
}

# Create the Cloud Function
resource "google_cloudfunctions_function" "chuck_norris_jokes" {
  name        = "chuck-norris-jokes"
  description = "Function that returns random Chuck Norris jokes"
  runtime     = "nodejs14"  # You can choose a different runtime like python38, go116, etc.

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_code.name
  trigger_http          = true
  entry_point           = "getRandomJoke"  # This should match the exported function name in your code
  
  environment_variables = {
    NODE_ENV = "production"
  }
}

# IAM entry to make the function publicly accessible
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.chuck_norris_jokes.project
  region         = google_cloudfunctions_function.chuck_norris_jokes.region
  cloud_function = google_cloudfunctions_function.chuck_norris_jokes.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"  # This makes it publicly accessible. For production, consider restricting access.
}

# Output the URL of the deployed function
output "function_url" {
  value = google_cloudfunctions_function.chuck_norris_jokes.https_trigger_url
}
