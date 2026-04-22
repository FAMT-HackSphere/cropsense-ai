# Deployment script for CropSense AI Backend
# This script builds the docker image using Google Cloud Build and deploys it to Cloud Run.

$PROJECT_ID = "cropsense-1b4dc"
$SERVICE_NAME = "cropsense-backend"
$REGION = "us-central1"

Write-Host "Deploying CropSense AI Backend to Cloud Run..." -ForegroundColor Cyan

# 1. Ensure gcloud is configured to the correct project
Write-Host "Setting gcloud project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# 2. Build and Push using Cloud Build (No local Docker needed!)
Write-Host "Building and pushing image via Cloud Build..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME

# 3. Deploy to Cloud Run
Write-Host "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME `
    --image gcr.io/$PROJECT_ID/$SERVICE_NAME `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "Please copy the Service URL provided above and paste it when I ask." -ForegroundColor Yellow
