import os
import sys

# Ensure ml mapping is accessible
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from ml import model_loader

def run_tests():
    print("=== Testing Model Loader ===")
    models = model_loader.load_all_models()
    
    if not models:
        print("No models found in the database. Ensure automated_trainer.py ran successfully.")
        return
        
    print(f"\nTotal models loaded successfully: {len(models)}")
    
    # Run a dummy prediction on the first available model
    test_model_name = "crop_recommendation_model"
    if test_model_name not in models:
        test_model_name = list(models.keys())[0]
        
    print(f"\nRunning test inference on -> '{test_model_name}'")
    
    # Define dummy inputs matching the training columns for crop recommendation
    # N,P,K,temperature,humidity,ph,rainfall
    if test_model_name == "crop_recommendation_model":
        dummy_input = {
            "N": 90,
            "P": 42,
            "K": 43,
            "temperature": 20.8,
            "humidity": 82.0,
            "ph": 6.5,
            "rainfall": 202.9
        }
    else:
        # Fallback to feature_i if name doesn't match
        model = models[test_model_name]
        num_features = getattr(model, "n_features_in_", 0)
        dummy_input = {f"feature_{i}": 0 for i in range(num_features)}
        
    try:
        res = model_loader.predict(test_model_name, dummy_input)
        
        if "error" in res:
            print(f"[FAIL] Inference Error: {res['error']}")
        else:
            print(f"[PASS] Inference Output: {res['prediction']}")
    except Exception as e:
         print(f"[FAIL] Hard Error: {e}")

if __name__ == "__main__":
    run_tests()
