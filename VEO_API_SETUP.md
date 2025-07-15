# Google Veo API Setup Guide

This guide will help you set up Google Cloud and Veo API for your app.

## Prerequisites

1. A Google Cloud account
2. A Google Cloud project with billing enabled
3. gcloud CLI installed on your machine

## Setup Steps

### 1. Install Google Cloud CLI

If you haven't already, install the Google Cloud CLI:

```bash
# For macOS with Homebrew
brew install --cask google-cloud-sdk
```

### 2. Initialize gcloud and authenticate

```bash
# Initialize gcloud
gcloud init

# Login to your Google account
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 3. Enable required APIs

```bash
# Enable Vertex AI API
gcloud services enable aiplatform.googleapis.com

# Enable required dependencies
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
```

### 4. Request access to Veo

1. Go to the [Veo waitlist form](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/video-generation#request-access)
2. Submit your request for access to Veo models
3. Wait for approval (this may take a few days)

### 5. Set up authentication for the app

For development, you can use your personal authentication:

```bash
# Generate an access token
gcloud auth print-access-token
```

Copy this token and set it as an environment variable before running your app:

```bash
export GOOGLE_CLOUD_ACCESS_TOKEN="ya29.your-token-here"
```

### 6. Update your app configuration

In `veo3/Config/GoogleCloudConfig.swift`, update the project ID:

```swift
static let projectId = "your-actual-project-id"
```

### 7. For production use

For production, you should use service account authentication:

1. Create a service account:
```bash
gcloud iam service-accounts create veo-app-service \
    --display-name="Veo App Service Account"
```

2. Grant necessary permissions:
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:veo-app-service@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user"
```

3. Create and download a key:
```bash
gcloud iam service-accounts keys create ~/veo-service-key.json \
    --iam-account=veo-app-service@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

4. Update the app to use service account authentication (requires additional implementation)

## Testing the Integration

1. Make sure you have set the access token:
```bash
export GOOGLE_CLOUD_ACCESS_TOKEN=$(gcloud auth print-access-token)
```

2. Run your app and select "Google Veo" as the provider
3. Select an image and enter a prompt
4. Generate a video!

## Troubleshooting

### Authentication errors
- Make sure your access token is fresh (they expire after 1 hour)
- Regenerate with `gcloud auth print-access-token`

### API not enabled errors
- Ensure all required APIs are enabled in your project
- Check the Google Cloud Console to verify

### Quota or permission errors
- Verify your project has billing enabled
- Check that you have been granted access to Veo models

## Important Notes

- Veo API is currently in preview and has usage limits
- The `veo-3.0-fast-generate-preview` model is optimized for speed
- Generated videos are 8 seconds long by default
- Always monitor your Google Cloud usage to avoid unexpected charges