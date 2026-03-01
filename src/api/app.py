from flask import Flask, request, jsonify
import joblib
import numpy as np
import os

app = Flask(__name__)

# Versão da aplicação
APP_VERSION = os.getenv("APP_VERSION", "v1.0.0")

model = joblib.load("iris-model.pkl")

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json["features"]
    prediction = model.predict([data])

    return jsonify({
        "prediction": prediction.tolist(),
        "version": APP_VERSION
    })

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "version": APP_VERSION
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

