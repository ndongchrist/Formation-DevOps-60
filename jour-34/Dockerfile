FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir
COPY app.py .
EXPOSE 5000 8000
CMD ["python", "app.py"]