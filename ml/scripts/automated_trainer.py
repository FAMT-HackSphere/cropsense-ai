import os
import time
import pandas as pd
import numpy as np
import joblib
import csv
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, precision_score, recall_score, mean_squared_error, r2_score

DATASET_DIR = r"d:\CropSense AI\cropsense-ai\datasets"
MODEL_DIR = r"d:\CropSense AI\cropsense-ai\ml\models"
REPORT_FILE = r"d:\CropSense AI\cropsense-ai\model_training_report.csv"

# Ensure models directory exists
os.makedirs(MODEL_DIR, exist_ok=True)

TARGET_KEYWORDS = ['crop', 'label', 'target', 'yield', 'production', 'fertilizer', 'recommendation']

def get_unique_filename(base_path):
    if not os.path.exists(base_path):
        return base_path
    base, ext = os.path.splitext(base_path)
    counter = 1
    while os.path.exists(f"{base}_{counter}{ext}"):
        counter += 1
    return f"{base}_{counter}{ext}"

def scan_and_train():
    report_data = []
    
    print(f"--- Scanning datasets in {DATASET_DIR} ---")
    
    for root, dirs, files in os.walk(DATASET_DIR):
        for file in files:
            if not file.endswith('.csv'): continue
                
            file_path = os.path.join(root, file)
            print(f"\n[+] Analyzing: {file}")
            start_time = time.time()
            
            try:
                df = pd.read_csv(file_path)
                
                if df.empty or len(df.columns) < 2:
                    print("    -> Skipped: Dataset is empty or has fewer than 2 columns.")
                    report_data.append([file, "N/A", "N/A", "N/A", "N/A", "Skipped: Empty/Corrupt"])
                    continue
                
                print(f"    Rows: {len(df)}, Columns: {len(df.columns)}")
                print(f"    Columns: {df.columns.tolist()}")
                
                # Drop all na subset or check missing
                missing_val_sum = df.isna().sum().sum()
                if missing_val_sum > 0:
                    print(f"    Missing values detected: {missing_val_sum}")
                    
                # Auto-detect target column
                target_col = None
                cols_lower = [c.lower() for c in df.columns]
                for kw in TARGET_KEYWORDS:
                    for i, c in enumerate(cols_lower):
                        if kw in c:
                            target_col = df.columns[i]
                            break
                    if target_col:
                        break
                
                if not target_col:
                    target_col = df.columns[-1]
                    
                print(f"    Auto-detected Target Column: {target_col}")
                
                # Check variance - if target is constant or everything is unique (like ID)
                if df[target_col].nunique() < 2:
                    print("    -> Skipped: Target column has less than 2 classes/values.")
                    report_data.append([file, target_col, "N/A", "N/A", "N/A", "Skipped: Constant Target"])
                    continue
                
                # Clean and prepare
                df = df.drop_duplicates()
                
                # Impute
                for col in df.columns:
                    if df[col].isna().any():
                        if pd.api.types.is_numeric_dtype(df[col]):
                            df[col] = df[col].fillna(df[col].median())
                        else:
                            df[col] = df[col].fillna(df[col].mode()[0])
                            
                # Drop constant features
                nunique = df.nunique()
                cols_to_drop = nunique[nunique == 1].index.tolist()
                cols_to_drop = [c for c in cols_to_drop if c != target_col]
                if cols_to_drop:
                    df = df.drop(columns=cols_to_drop)
                    
                # Encode categorical features
                le_dict = {}
                for col in df.select_dtypes(include=['object', 'category']).columns:
                    # we must also encode target if it is object
                    df[col] = df[col].astype(str)
                    le = LabelEncoder()
                    df[col] = le.fit_transform(df[col])
                    if col == target_col:
                        le_dict[target_col] = le
                        
                X = df.drop(columns=[target_col])
                y = df[target_col]
                
                # Train/test split
                if len(df) < 10:
                    print("    -> Skipped: Not enough rows to split reliably.")
                    report_data.append([file, target_col, "N/A", "N/A", "N/A", "Skipped: Too Few Rows"])
                    continue
                    
                X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
                
                is_classification = False
                # If target is categorical or has few unique integers (<20), it's classification
                # If target was originally float, or has many unique numbers, it's regression
                if y.dtype in ['int32', 'int64'] and y.nunique() < min(30, len(y)/5):
                    is_classification = True
                elif target_col in le_dict:
                    is_classification = True

                metric_res = ""
                
                if is_classification:
                    print("    Task: Classification")
                    model = RandomForestClassifier(n_estimators=50, max_depth=10, n_jobs=-1, random_state=42)
                    model.fit(X_train, y_train)
                    y_pred = model.predict(X_test)
                    acc = accuracy_score(y_test, y_pred)
                    prec = precision_score(y_test, y_pred, average='weighted', zero_division=0)
                    rec = recall_score(y_test, y_pred, average='weighted', zero_division=0)
                    print(f"    Metrics -> Accuracy: {acc:.4f}, Precision: {prec:.4f}, Recall: {rec:.4f}")
                    metric_res = f"Acc: {acc:.4f}"
                else:
                    print("    Task: Regression")
                    if len(df) > 10000:
                        model = RandomForestRegressor(n_estimators=50, max_depth=10, n_jobs=-1, random_state=42)
                    else:
                        model = LinearRegression()
                    model.fit(X_train, y_train)
                    y_pred = model.predict(X_test)
                    mse = mean_squared_error(y_test, y_pred)
                    r2 = r2_score(y_test, y_pred)
                    print(f"    Metrics -> MSE: {mse:.4f}, R2: {r2:.4f}")
                    metric_res = f"MSE: {mse:.4f}"
                    
                # Save model
                base_name = os.path.splitext(file)[0].replace(' ', '_').lower()
                save_path = os.path.join(MODEL_DIR, f"{base_name}_model.pkl")
                save_path = get_unique_filename(save_path)
                
                joblib.dump(model, save_path)
                print(f"    Saved model to: {save_path}")
                
                end_time = time.time()
                train_time = round(end_time - start_time, 2)
                
                report_data.append([
                    file, 
                    target_col, 
                    model.__class__.__name__, 
                    metric_res, 
                    f"{train_time}s", 
                    "Success"
                ])
                
            except Exception as e:
                print(f"    -> Error parsing/training: {str(e)}")
                report_data.append([file, "N/A", "N/A", "N/A", "N/A", f"Error: {str(e)}"])
                
    # Generate report
    with open(REPORT_FILE, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(["Dataset Name", "Target Column", "Model Used", "Primary Metric", "Training Time", "Status"])
        writer.writerows(report_data)
        
    print(f"\n--- Summary ---")
    print(f"Total files scanned: {len(report_data)}")
    success = sum(1 for r in report_data if r[5] == "Success")
    print(f"Total models trained: {success}")
    print(f"Total skipped/failed: {len(report_data) - success}")
    print(f"Models directory: {MODEL_DIR}")
    print(f"Report generated: {REPORT_FILE}")

if __name__ == "__main__":
    scan_and_train()
