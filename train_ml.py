import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, mean_squared_error
import joblib

dataset_dir = r"d:\CropSense AI\cropsense-ai\datasets"
if not os.path.isdir(dataset_dir):
    print("Invalid dataset folder. Exiting.")
    exit()

csv_files = [f for f in os.listdir(dataset_dir) if f.endswith('.csv')]
if not csv_files:
    print('No CSV files found. Exiting.')
    exit()

for csv_file in csv_files:
    file_path = os.path.join(dataset_dir, csv_file)
    print(f'\nProcessing: {csv_file}')
    
    df = pd.read_csv(file_path)
    cols = df.columns.tolist()
    
    # Auto-detect target column
    possible_targets = [c for c in cols if c.lower() in ['yield','production','crop','target']]
    target_col = possible_targets[0] if possible_targets else cols[-1]
    print(f'Using "{target_col}" as target column.')
    
    # Encode categorical features
    for col in df.select_dtypes(include=['object']).columns:
        if col != target_col:
            df[col] = LabelEncoder().fit_transform(df[col].astype(str))
    
    # Split data
    X = df.drop(columns=[target_col])
    y = df[target_col]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Choose model
    model = LinearRegression() if y.dtype in ['int64','float64'] else RandomForestClassifier(n_estimators=100, random_state=42)
    
    # Train and evaluate
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    if y.dtype in ['int64','float64']:
        print('MSE:', mean_squared_error(y_test, y_pred))
    else:
        print('Accuracy:', accuracy_score(y_test, y_pred))
    
    # Save model
    model_file = os.path.join(dataset_dir, os.path.splitext(csv_file)[0] + '_model.pkl')
    joblib.dump(model, model_file)
    print(f'Model saved as {model_file}')

print('\nAll CSV files processed. ML models trained and saved successfully!')
