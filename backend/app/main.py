from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import crop, fertilizer, rotation, economics, health

app = FastAPI(
    title="CropSense AI",
    description="AI-powered agriculture recommendation system",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(crop.router, prefix="/api/crop", tags=["Crop Prediction"])
app.include_router(fertilizer.router, prefix="/api/fertilizer", tags=["Fertilizer Recommendation"])
app.include_router(rotation.router, prefix="/api/rotation", tags=["Crop Rotation"])
app.include_router(economics.router, prefix="/api/economics", tags=["Economic Analysis"])
app.include_router(health.router, prefix="/api/health", tags=["Health Check"])

@app.get("/")
async def root():
    return {"message": "CropSense AI Backend Running"}
