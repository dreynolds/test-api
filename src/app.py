from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def index():
    with open('/etc/hostname', 'r') as fp:
        host = fp.read()

    data = {
        'container_id': host.strip(),
    }
    return jsonify(data)