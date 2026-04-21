from flask import Flask, request
from prometheus_client import Counter, Histogram, start_http_server
import time, random

app = Flask(__name__)

# Définir des métriques
REQUEST_COUNT = Counter('app_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('app_request_duration_seconds', 'Request latency', ['endpoint'])

@app.route('/api/data')
@REQUEST_LATENCY.labels(endpoint='/api/data').time()
def get_data():
    try:
        # Simuler un traitement
        time.sleep(random.uniform(0.1, 0.3))
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='200').inc()
        return {'data': 'OK'}, 200
    except Exception as e:
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='500').inc()
        return {'error': str(e)}, 500

@app.route('/metrics')  # Endpoint exposé pour Prometheus
def metrics():
    from prometheus_client import generate_latest
    return generate_latest()

if __name__ == '__main__':
    start_http_server(8000)  # Expose /metrics sur le port 8000
    app.run(host='0.0.0.0', port=5000)  # App principale sur le port 5000