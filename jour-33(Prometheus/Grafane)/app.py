from flask import Flask, request, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = Flask(__name__)

# 1. Define Metrics
# Counter: http_requests_total{method, endpoint, status}
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'status'])

# Histogram: http_request_duration_seconds{method, endpoint}
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP Request Latency', ['method', 'endpoint'])

# Gauge: app_active_workers
ACTIVE_WORKERS = Gauge('app_active_workers', 'Number of active workers')
ACTIVE_WORKERS.set(1) # Simulating a static worker count for demo

# 2. Middleware to capture metrics
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - request.start_time
    REQUEST_COUNT.labels(
        method=request.method, 
        endpoint=request.path, 
        status=response.status_code
    ).inc()
    
    REQUEST_LATENCY.labels(
        method=request.method, 
        endpoint=request.path
    ).observe(duration)
    
    return response

# 3. Application Endpoints
@app.route('/')
def home():
    # Simulate some work
    time.sleep(random.uniform(0.1, 0.5))
    return jsonify({"message": "Hello World"})

@app.route('/fail')
def fail():
    # Simulate an error
    return jsonify({"error": "Internal Server Error"}), 500

# 4. Metrics Endpoint (Prometheus scrapes this)
@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    # Host 0.0.0.0 is crucial for Kubernetes
    app.run(host='0.0.0.0', port=5000)