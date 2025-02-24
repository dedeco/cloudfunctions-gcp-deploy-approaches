# Chuck Norris Jokes Cloud Function

A simple Google Cloud Function that returns random Chuck Norris jokes.

## Files

- `index.js`: The main Cloud Function code
- `package.json`: Node.js package definition

## Deployment

To deploy this function, use the `deploy-function.sh` script:

```bash
./deploy-function.sh PROJECT_ID [REGION] [FUNCTION_NAME]
```

Where:
- `PROJECT_ID` is your Google Cloud project ID
- `REGION` is the region to deploy to (defaults to us-central1)
- `FUNCTION_NAME` is the name for your function (defaults to chuck-norris-jokes)

## Testing

After deployment, you can test the function with curl:

```bash
curl https://REGION-PROJECT_ID.cloudfunctions.net/FUNCTION_NAME
```
