import firebase_admin
from firebase_admin import credentials, firestore
import os
from dotenv import load_dotenv

load_dotenv()

# Firebase credentials path
# Aligning with user's requested naming convention
cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", os.getenv("FIREBASE_CREDENTIAL_PATH", "serviceAccountKey.json"))
database_id = os.getenv("FIRESTORE_DATABASE", "(default)")

import json

# Initialize Firebase Admin SDK
if not firebase_admin._apps:
    try:
        # 1. Try loading from Environment Variable JSON string (Priority for Render)
        firebase_key = os.getenv("FIREBASE_KEY")
        if firebase_key:
            # Check if it's a file path or direct JSON
            if firebase_key.endswith(".json") and os.path.exists(firebase_key):
                cred = credentials.Certificate(firebase_key)
            else:
                # Assume it's a raw JSON string
                cred_dict = json.loads(firebase_key)
                cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
            print("Firebase initialized from Environment Variable")
        
        # 2. Fallback to local file path
        else:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print(f"Firebase initialized from local file: {cred_path}")
            
        print("Firestore Connected")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")

# Export the Firestore client
db = firestore.client(database_id=database_id)
