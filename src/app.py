from flask import Flask, jsonify, request
from auth import decode_jwt

app = Flask(__name__)


@app.route('/')
def index():
    with open('/etc/hostname', 'r') as fp:
        host = fp.read()

    response_data = {
        'container_id': host.strip(),
    }

    authorization = request.headers.get('Authorization', None)
    if authorization:
        decoded_jwt = decode_jwt(authorization)
        response_data['jwt'] = decoded_jwt
    return jsonify(response_data)
