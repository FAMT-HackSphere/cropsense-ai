import os
import joblib
import logging
import pandas as pd

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MODEL_DIR = os.path.join(os.path.dirname(__file__), "models")
_MODELS = {}

def load_all_models():
    """
    Loads all required models and dependent encoders from the models directory.
    """
    global _MODELS
    _MODELS.clear()

    # Also load common encoders/scalers that might be needed by multiple services
    if not os.path.exists(MODEL_DIR):
        logger.error(f"Model directory {MODEL_DIR} not found!")
        return _MODELS

    for filename in os.listdir(MODEL_DIR):
        if filename.endswith(".pkl"):
            model_key = os.path.splitext(filename)[0]
            file_path = os.path.join(MODEL_DIR, filename)
            try:
                model = joblib.load(file_path)
                _MODELS[model_key] = model
                logger.info(f"Loaded {model_key}")
            except Exception as e:
                logger.error(f"Failed to load {model_key}: {e}")

    return _MODELS

def get_model(model_name):
    """
    Retrieves a cached model or encoder.
    """
    if not _MODELS:
        load_all_models()
    return _MODELS.get(model_name)

def predict(model_key, input_dict):
    """
    Runs prediction for a given model key and input dictionary.
    """
    model = get_model(model_key)
    if not model:
        raise ValueError(f"Model {model_key} not loaded.")
    
    # Convert input to DataFrame
    df = pd.DataFrame([input_dict])
    
    # Run prediction
    prediction = model.predict(df)
    return prediction.tolist()

# Initial load on import
load_all_models()
