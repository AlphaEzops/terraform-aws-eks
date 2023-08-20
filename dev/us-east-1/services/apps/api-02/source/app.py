from flask import Flask, make_response

app = Flask(__name__)

@app.route('/')
def root():
    return make_response("Hello World - Python!", 200)

@app.route('/healthz')
def health():
    return make_response("Health", 200)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=9555)