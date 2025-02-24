When you deploy your function's source code to Cloud Run functions, that source is stored in a Cloud Storage bucket. Cloud Build then automatically builds your code into a container image and pushes that image to an image registry. Cloud Run functions accesses this image when it needs to run the container to execute your function. 


[Documentation](https://cloud.google.com/functions/docs/building#secure_your_build_with_a_custom_service_account)
