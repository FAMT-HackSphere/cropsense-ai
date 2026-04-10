from fastapi.testclient import TestClient
from main import app
import pytest

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["model_count"] == 5

def test_predict_crop():
    sample_data = {
        "nitrogen": 90,
        "phosphorus": 42,
        "potassium": 43,
        "temperature": 20.8,
        "humidity": 82.0,
        "ph": 6.5,
        "rainfall": 202.9
    }
    response = client.post("/predict/crop", json=sample_data)
    assert response.status_code == 200
    assert "recommended_crop" in response.json()

def test_predict_fertilizer():
    sample_data = {
        "nitrogen": 30,
        "phosphorus": 10,
        "potassium": 20,
        "ph": 6.0,
        "temperature": 25,
        "humidity": 70,
        "rainfall": 150
    }
    response = client.post("/predict/fertilizer", json=sample_data)
    assert response.status_code == 200
    assert "recommended_fertilizer" in response.json()

def test_predict_rotation():
    sample_data = {
        "current_crop": "rice",
        "season": "Kharif"
    }
    response = client.post("/predict/rotation", json=sample_data)
    assert response.status_code == 200
    assert "recommended_next_crop" in response.json()

def test_predict_seed():
    sample_data = {
        "crop_name": "rice",
        "soil_type": "Clayey"
    }
    response = client.post("/predict/seed", json=sample_data)
    assert response.status_code == 200
    assert "recommended_seed_variety" in response.json()

def test_predict_economic():
    sample_data = {
        "crop_name": "rice",
        "yield_amount": 1000,
        "market_price": 20.5,
        "seed_cost": 500,
        "fertilizer_cost": 300,
        "labor_cost": 1000,
        "irrigation_cost": 200
    }
    response = client.post("/predict/economic", json=sample_data)
    assert response.status_code == 200
    assert "predicted_profit" in response.json()
