import pytest
import threading
import time
from flask import Flask, make_response
import requests

# Start the Flask app in a separate thread
def start_app():
    app.run(debug=True, host="0.0.0.0", port=5000)

app = Flask(__name__)

@app.route('/')
def root():
    return make_response("Hello World - Python!", 200)

@app.route('/healthz')
def health():
    return make_response("Health", 200)

# Create a fixture to start and stop the app for testing
@pytest.fixture(scope="module")
def app_fixture():
    thread = threading.Thread(target=start_app)
    thread.daemon = True
    thread.start()
    time.sleep(1)  # Give the app some time to start
    yield app
    thread.join(1)

# Test the root route
def test_root_route(app_fixture):
    response = requests.get('http://127.0.0.1:5000/')
    assert response.status_code == 200
    assert response.text == "Hello World - Python!"

# Test the health route
def test_health_route(app_fixture):
    response = requests.get('http://127.0.0.1:5000/healthz')
    assert response.status_code == 200
    assert response.text == "Health"
