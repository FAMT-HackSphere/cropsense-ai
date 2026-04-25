# CropSense AI 🌱

CropSense AI is an intelligent agricultural assistant system designed to help farmers make data-driven decisions. It provides recommendations for crops, fertilizers, crop rotation, and economic profitability based on environmental factors like soil type, temperature, and rainfall.

## 🏗 Architecture

- **Frontend**: Flutter mobile application providing an intuitive and accessible interface for farmers.
- **Backend**: FastAPI Python server serving machine learning predictions and managing data.
- **Machine Learning**: Scikit-learn models (Random Forest, Decision Trees, Linear Regression) trained on historical agricultural data.
- **Database**: Firebase Firestore for storing user history and app configurations.
- **Deployment**: Configured for Render (Backend) and easily buildable as an Android APK (Frontend).

## 📂 Project Structure

```
.
├── backend/            # FastAPI server, API routes, and loaded ML models
├── frontend/           # Flutter application source code and assets
├── ml/                 # Machine learning training scripts, notebooks, and datasets
│   ├── scripts/        # Automated training and preprocessing scripts
│   ├── datasets/       # Raw and processed datasets
│   └── notebooks/      # Exploratory Data Analysis (EDA) Jupyter notebooks
├── data/               # Static reference JSON data (crops, fertilizers, etc.)
├── scripts/            # Utility scripts (e.g., Firestore data validation)
├── deployment/         # Cloud deployment templates and scripts
└── docs/               # Technical documentation and API references
```

## 🚀 Features

1. **Smart Crop Recommendation**: Suggests the best crop to plant based on soil nutrients (N, P, K), pH, and weather conditions.
2. **Fertilizer Prediction**: Recommends the optimal fertilizer type based on current soil conditions and the crop being grown.
3. **Crop Rotation Planning**: Suggests the next best crop to plant in a rotation cycle to maintain soil health.
4. **Economic Forecasting**: Estimates potential yield and profit based on land area, market prices, and farming costs.
5. **Localization**: Supports multiple languages (English, Hindi, Marathi, Haryanvi) to cater to diverse regions.

## 🛠 Setup & Installation

### 1. Backend (FastAPI)
The backend is configured to run on Render, but can be run locally:

```bash
cd backend
python -m venv venv
# On Windows: venv\Scripts\activate
# On Mac/Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```
*Note: You must place your `serviceAccountKey.json` from Firebase in the `backend/` directory.*

### 2. Frontend (Flutter)
The frontend connects to the deployed backend URL by default.

```bash
cd frontend
flutter pub get
flutter run
```
*To build a release APK for Android:*
```bash
flutter build apk --release
```

## 🔒 Environment Variables

Ensure the following variables are set in your production environment (e.g., Render):
- `PYTHON_VERSION`: `3.10.12`
- `FIREBASE_KEY`: Your Firebase Service Account JSON (as a Secret File or string).

## 📄 License
This project is licensed under the MIT License. See the `LICENSE` file for details.
