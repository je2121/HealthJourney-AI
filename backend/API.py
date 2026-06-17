from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pydantic
import joblib
import pandas as pd
import numpy as np

app = FastAPI(
    title="Personal Health Predictive Analytics Engine",
    version="1.0.0"
)

# Mengizinkan koneksi lintas platform (CORS) agar Flutter bisa mengakses API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. Load trained joblib pipeline
model_pipeline = None
try:
    model_pipeline = joblib.load("xgb_model.pkl")
    print("🎯 Success: Model loaded perfectly!")
except Exception as e:
    print(f"❌ Error loading model file: {e}")

# 2. Struktur Payload Data dari Flutter
class MobileHealthInput(pydantic.BaseModel):
    gender_encoded: int
    age: float
    sleep_duration: float
    physical_activity_level: float
    weight: float             
    height: float             
    heart_rate: float
    daily_steps: float
    sleep_disorder_encoded: int

# 3. Endpoint Eksekusi Prediksi AI
@app.post("/predict")
def predict_health_trends(data: MobileHealthInput):
    if model_pipeline is None:
        return {"status": "error", "message": "Model pipeline is not loaded on the server."}
        
    # --- STEP A: KALKULASI BMI BACKEND ---
    height_m = data.height / 100.0
    bmi_score = data.weight / (height_m ** 2)
    
    if bmi_score < 25.0:
        bmi_category_encoded = 0   
        bmi_category_text = "Normal Weight"
    elif 25.0 <= bmi_score < 30.0:
        bmi_category_encoded = 1   
        bmi_category_text = "Overweight"
    else:
        bmi_category_encoded = 2   
        bmi_category_text = "Obese"
        
    # --- STEP B: SUSUN DATAFRAME (URUTAN & KAPITALISASI 100% SAMA DENGAN JUPYTER) ---
    # Diperbaiki agar urutan kolom sesuai dengan 'new_sample' di Notebook Anda
    input_df = pd.DataFrame([{
        'Gender': data.gender_encoded,
        'Age': data.age,
        'Sleep Duration': data.sleep_duration,
        'Physical Activity Level': data.physical_activity_level,
        'BMI Category': bmi_category_encoded,
        'Heart Rate': data.heart_rate,
        'Daily Steps': data.daily_steps,
        'Sleep Disorder': data.sleep_disorder_encoded
    }])
    
    # Reorder kolom secara eksplisit untuk memastikan urutan tidak bergeser
    input_df = input_df[['Gender', 'Age', 'Sleep Duration', 'Physical Activity Level', 'BMI Category', 'Heart Rate', 'Daily Steps', 'Sleep Disorder']]
    
    # --- STEP C: EKSEKUSI PREDIKSI MODEL AI ---
    prediction = model_pipeline.predict(input_df)
    
    sleep_quality_prediction = float(prediction[0][0])
    stress_prediction = float(prediction[0][1])
    
    # --- STEP D: MENGEMBALIKAN DATA JSON UTK FLUTTER ---
    return {
        "bmi_score": float(bmi_score),
        "bmi_category": bmi_category_text,
        "sleep_quality": sleep_quality_prediction,
        "stress_level": stress_prediction
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("API:app", host="0.0.0.0", port=8000, reload=True)