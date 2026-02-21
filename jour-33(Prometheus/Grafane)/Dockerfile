FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Use gunicorn for production-like behavior
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]