from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd
import os

app = Flask(__name__)
CORS(app)

model_data = joblib.load("model.pkl") if os.path.exists("model.pkl") else None
model = model_data["model"] if model_data else None
scaler = model_data["scaler"] if model_data else None
feature_names = model_data["feature_names"] if model_data else None


@app.route("/", methods=["GET"])
def home():
    status = model is not None
    code = 200 if status else 503
    return jsonify({
        "status": "success" if status else "error",
        "model_loaded": status,
        "features": feature_names if status else None,
        "message": "Heart Disease API is running" if status else "Model not loaded"
    }), code


@app.route("/predict", methods=["POST"])
def predict():
    if not (model and scaler and feature_names):
        return jsonify({"error": "Model not loaded"}), 500

    data = request.get_json(force=True) or {}
    missing = [f for f in feature_names if f not in data]
    if missing:
        return jsonify({
            "error": f"Missing fields: {missing}",
            "required_fields": feature_names
        }), 400

    df = pd.DataFrame([data], columns=feature_names)
    X = scaler.transform(df)

    proba = model.predict_proba(X)[0]
    pred = int(proba[1] >= 0.5)

    return jsonify({
        "prediction": pred,
        "probability": float(proba[1] * 100),
        "details": {
            "no_disease": float(proba[0] * 100),
            "disease": float(proba[1] * 100)
        }
    }), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None
    }), 200


@app.errorhandler(404)
def not_found(_):
    return jsonify({
        "error": "Endpoint not found",
        "available_endpoints": ["/", "/predict", "/health"]
    }), 404


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
