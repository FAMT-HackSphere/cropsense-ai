import sys
import os
from fastapi.testclient import TestClient

# Add backend to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "backend"))

from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "CropSense AI Backend Running"}

def test_predict_crop():
    payload = {
        "state": "Maharashtra",
        "district": "Pune",
        "soil_type": "Black",
        "nitrogen": 90,
        "phosphorus": 42,
        "potassium": 43,
        "ph": 6.5,
        "rainfall": 202.9,
        "temperature": 20.8,
        "humidity": 82.0,
        "season": "Kharif",
        "land_size": 2.5,
        "budget": 10000,
        "irrigation": True
    }
    response = client.post("/api/crop/predict-crop", json=payload)
    if response.status_code != 200:
        print(f"FAILED: {response.status_code}")
        print(response.json())
    assert response.status_code == 200
    data = response.json()
    assert "recommended_crop" in data
    assert data["recommended_crop"] == "Rice"
    print(f"Test Predict Crop PASSED: {data['recommended_crop']}")

if __name__ == "__main__":
    test_read_root()
    test_predict_crop()
    print("All integration tests PASSED!")
