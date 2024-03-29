import json
import logging
import os
import uuid
from datetime import datetime

from flask import Flask, request, jsonify

app = Flask(__name__)
logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s] [%(process)d] [%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)

username = os.environ['AICOVERS_API_USERNAME']
password = os.environ['AICOVERS_API_PASSWORD']
queue_dir = os.environ['AICOVERS_REQUESTS_DIR']


def check_auth(user, pwd):
    return username == user and password == pwd


def authenticate():
    logger.error("Unauthorized")
    return jsonify({'message': 'Authentication required'}), 401


def save_request_to_file(data):
    if not os.path.exists(queue_dir):
        os.makedirs(queue_dir)

    filename = f"{data['created_at']}_{data['id']}.json"
    filepath = os.path.join(queue_dir, filename)

    with open(filepath, 'w') as f:
        f.write(json.dumps(data, indent=2, ensure_ascii=False))

    return filename


@app.route('/aicovers', methods=['POST'])
def handle_request():
    logger.info(f"Handing incoming request {json.dumps(request.json)} ...")
    auth = request.authorization

    if not auth or not check_auth(auth.username, auth.password):
        return authenticate()

    request_body = request.json
    if not request_body \
            or 'youtube' not in request_body \
            or 'model' not in request_body \
            or 'webhook_url' not in request_body:
        return jsonify({'message': 'Invalid request body'}), 400

    id = str(uuid.uuid4())
    created_at = datetime.utcnow().isoformat()[:-3]+'Z'

    response_body = {
        'id': id,
        'created_at': created_at,
        'youtube': request_body['youtube'],
        'model': request_body['model'],
        'webhook_url': request_body['webhook_url']
    }

    save_request_to_file(response_body)

    logger.info(f"Handled incoming request. Response {json.dumps(response_body)}!")
    return jsonify(response_body)


if __name__ == '__main__':
    app.run(port=5001)
