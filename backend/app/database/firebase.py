import firebase_admin
from firebase_admin import credentials, firestore
import os
from dotenv import load_dotenv

load_dotenv()

# Firebase credentials path
# Aligning with user's requested naming convention
cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", os.getenv("FIREBASE_CREDENTIAL_PATH", "serviceAccountKey.json"))
database_id = os.getenv("FIRESTORE_DATABASE", "(default)")

# Initialize Firebase Admin SDK
if not firebase_admin._apps:
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print(f"Firestore initialized successfully. Project: {cred.project_id}, Database: {database_id}")
        print("Firestore Connected")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        # In case of error, you might want to handle it (e.g., using a mock client)
        pass

# Export the Firestore client
db = firestore.client(database_id=database_id)
