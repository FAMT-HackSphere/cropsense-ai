import joblib
import os

model_dir = "d:/CropSense AI/cropsense-ai/backend/models"
model_path = os.path.join(model_dir, "crop_recommendation_model.pkl")

if os.path.exists(model_path):
    model = joblib.load(model_path)
    if hasattr(model, "classes_"):
        print(f"Model classes: {list(model.classes_)}")
    else:
        print("Could not find classes in model")
else:
    print("crop_recommendation_model.pkl not found")
