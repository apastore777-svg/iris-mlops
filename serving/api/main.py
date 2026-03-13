from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import numpy as np
import joblib

app = FastAPI()

# carregar modelo no startup do container
model = joblib.load("/app/model/model.pkl")


@app.get("/ping")
def ping():
    return {"status": "ok"}


@app.post("/invocations")
async def invocations(request: Request):

    payload = await request.json()

    if "features" in payload:
        features = payload["features"]

    elif "instances" in payload:
        features = payload["instances"][0]

    elif isinstance(payload, list):
        features = payload[0]

    else:
        raise ValueError(f"Unsupported payload format: {payload}")

    arr = np.array([features])

    pred = model.predict(arr)

    result = {
        "prediction": pred.tolist(),
        "version": "2.0.0"
    }

    return JSONResponse(content=result)
