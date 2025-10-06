# POC - Cloud Run CI/CD Setup

This repository demonstrates a complete CI/CD pipeline for deploying a simple HTML application to Google Cloud Run.

## Prerequisites

1. **Google Cloud Project**: Create or have access to a GCP project
2. **Enable APIs**: Enable Cloud Run, Cloud Build, and Artifact Registry APIs
3. **Service Account**: Create a service account with necessary permissions
4. **GitHub Secrets**: Configure repository secrets for authentication

## Setup Instructions

### 1. Google Cloud Setup

```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Create Artifact Registry repository
gcloud artifacts repositories create poc-html-app \
    --repository-format=docker \
    --location=us-central1 \
    --description="Docker repository for POC HTML app"

# Create service account
gcloud iam service-accounts create github-actions \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

# Generate service account key
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@$PROJECT_ID.iam.gserviceaccount.com
```

### 2. GitHub Repository Setup

Add the following secrets to your GitHub repository:

1. **GCP_PROJECT_ID**: Your Google Cloud project ID
2. **GCP_SA_KEY**: The entire content of the `key.json` file

To add secrets:
1. Go to your repository on GitHub
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add both secrets

### 3. Deployment Options

#### Option A: GitHub Actions (Recommended)
- Push to `main` branch triggers automatic deployment
- Uses `.github/workflows/deploy.yml`
- Provides complete CI/CD pipeline

#### Option B: Google Cloud Build
```bash
# Manual deployment using Cloud Build
gcloud builds submit --config cloudbuild.yaml
```

#### Option C: Local Docker Build and Deploy
```bash
# Build locally
docker build -t poc-html-app .

# Tag for Artifact Registry
docker tag poc-html-app us-central1-docker.pkg.dev/$PROJECT_ID/poc-html-app/poc-html-app:latest

# Push to registry
docker push us-central1-docker.pkg.dev/$PROJECT_ID/poc-html-app/poc-html-app:latest

# Deploy to Cloud Run
gcloud run deploy poc-html-app \
    --image us-central1-docker.pkg.dev/$PROJECT_ID/poc-html-app/poc-html-app:latest \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8080
```

## File Structure

```
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── index.html                  # Main HTML application
├── Dockerfile                  # Container configuration
├── nginx.conf                  # Nginx web server configuration
├── cloudbuild.yaml            # Google Cloud Build configuration
├── service.yaml               # Cloud Run service configuration
├── .env.example              # Environment variables template
└── README.md                 # This file
```

## Features

- **Containerized Deployment**: Uses Docker with Nginx for optimal performance
- **Auto-scaling**: Cloud Run automatically scales based on traffic
- **Health Checks**: Built-in health endpoint at `/health`
- **Security Headers**: Configured security headers in Nginx
- **Gzip Compression**: Enabled for better performance
- **Static Asset Caching**: Optimized caching for static files

## Monitoring and Logs

```bash
# View service logs
gcloud run services logs read poc-html-app --region=us-central1

# Get service details
gcloud run services describe poc-html-app --region=us-central1
```

## Customization

- **Service Name**: Update `SERVICE` in `.github/workflows/deploy.yml`
- **Region**: Change `REGION` and `GAR_LOCATION` as needed
- **Resources**: Modify CPU/memory limits in `service.yaml`
- **Scaling**: Adjust `maxScale` in service annotations

## Troubleshooting

1. **Permission Errors**: Ensure service account has all required roles
2. **Build Failures**: Check Dockerfile syntax and base image availability
3. **Deployment Issues**: Verify Cloud Run service configuration
4. **Network Issues**: Ensure port 8080 is properly configured

For more information, see [Google Cloud Run Documentation](https://cloud.google.com/run/docs).