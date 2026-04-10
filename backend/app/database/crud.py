from app.database.firebase import db
from datetime import datetime

# Generic CRUD operations for Firestore

def create_document(collection: str, data: dict):
    # Add timestamp if not present
    if "timestamp" not in data:
        data["timestamp"] = datetime.utcnow()
    doc_ref = db.collection(collection).document()
    doc_ref.set(data)
    return doc_ref.id

def get_document(collection: str, doc_id: str):
    doc_ref = db.collection(collection).document(doc_id)
    doc = doc_ref.get()
    return doc.to_dict() if doc.exists else None

def update_document(collection: str, doc_id: str, data: dict):
    doc_ref = db.collection(collection).document(doc_id)
    doc_ref.update(data)
    return doc_id

def delete_document(collection: str, doc_id: str):
    doc_ref = db.collection(collection).document(doc_id)
    doc_ref.delete()
    return doc_id

def query_documents(collection: str, field: str, operator: str, value: any):
    docs = db.collection(collection).where(field, operator, value).stream()
    return [{doc.id: doc.to_dict()} for doc in docs]

# Specific CRUD helpers
def get_market_price(crop_name: str):
    prices = db.collection("market_prices").where("crop_name", "==", crop_name).stream()
    for doc in prices:
        return doc.to_dict().get("price", 0.0)
    return None

def save_history(data: dict):
    return create_document("history", data)
