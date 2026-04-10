import firebase_admin
from firebase_admin import credentials, firestore
import os

# Firebase credentials path
cred_path = r"d:\CropSense AI\cropsense-ai\backend\serviceAccountKey.json"
database_id = os.getenv("FIRESTORE_DATABASE", "(default)")

if not firebase_admin._apps:
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print(f"Firebase Admin SDK initialized. Project: {cred.project_id}")
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        exit(1)

# Initialize the Firestore client
try:
    db = firestore.client(database_id=database_id)
    print(f"Firestore client created for Database: {database_id}")
    
    # Try a simple write
    print("Testing write operation...")
    doc_ref = db.collection('test_connection').document('connectivity_check')
    doc_ref.set({
        'status': 'success',
        'message': 'Firestore connectivity verified',
        'timestamp': firestore.SERVER_TIMESTAMP
    })
    print("Write operation successful.")
    
    # Try a simple read
    print("Testing read operation...")
    doc = doc_ref.get()
    if doc.exists:
        print(f"Read operation successful: {doc.to_dict()}")
    else:
        print("Read operation failed: Document does not exist.")
except Exception as e:
    print(f"Firestore Operation Error: {e}")
