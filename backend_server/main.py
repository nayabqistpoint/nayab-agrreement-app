from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import easyocr
import io
import numpy as np
from PIL import Image
import pypdfium2 as pdfium

app = FastAPI(title="Nayab Qist Point OCR Server")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("ماڈل لوڈ ہو رہا ہے، براہ کرم چند سیکنڈ انتظار کریں...")
reader = easyocr.Reader(['ur', 'en'], gpu=False)
print("او سی آر سرور مکمل طور پر تیار ہے!")

@app.get("/")
def home():
    return {
        "status": "online",
        "message": "او سی آر سرور کامیابی سے چل رہا ہے!"
    }

@app.post("/scan-document")
async def scan_document(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        filename = file.filename.lower()
        extracted_text_list = []

        # اگر فائل پی ڈی ایف (PDF) ہو
        if filename.endswith(".pdf"):
            pdf = pdfium.PdfDocument(contents)
            for page_index in range(len(pdf)):
                page = pdf[page_index]
                pil_image = page.render(scale=2).to_pil()
                img_array = np.array(pil_image)
                results = reader.readtext(img_array, detail=0)
                extracted_text_list.extend(results)
        
        # اگر فائل عام تصویر (JPG یا PNG) ہو
        else:
            pil_image = Image.open(io.BytesIO(contents)).convert("RGB")
            img_array = np.array(pil_image)
            results = reader.readtext(img_array, detail=0)
            extracted_text_list.extend(results)

        full_text = "\n".join(extracted_text_list)
        
        return {
            "status": "success",
            "filename": file.filename,
            "text": full_text
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }