import logging
import os
import sys

import requests
import json
import shutil
import time
import traceback

from main import song_cover_pipeline

logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s] [%(process)d] [%(levelname)s] %(message)s')
logger = logging.getLogger(__name__)

queue_dir = os.environ['AICOVERS_REQUESTS_DIR']
archive_dir = os.environ['AICOVERS_ARCHIEVE_DIR']
dlq_dir = os.environ['AICOVERS_DLQ_DIR']


def main():
    while True:
        time.sleep(0.5)
        files = sorted(os.listdir(queue_dir))
        logger.info(f"Found [{len(files)}] requests to process: {files}")

        for filename in files:
            data = None
            logger.info(f"Processing [{filename}] ...")
            filepath = os.path.join(queue_dir, filename)
            with open(filepath, 'r', encoding='utf-8') as file:
                time.sleep(0.5)
                try:
                    data = json.load(file)
                    result_path = song_cover_pipeline(data['youtube'], data['model'], shorten_to=data.get('shorten_to', None))
                    data['result_path'] = result_path
                    logger.info(f'Result has been stored at {result_path}')
                    webhook(data)

                    with open(filepath, 'w', encoding='utf-8') as modified_file:
                        json.dump(data, modified_file, indent=2, ensure_ascii=False)

                    shutil.move(filepath, os.path.join(archive_dir, filename))
                    logger.info(f"Successfully processed request [{filename}]!")
                except Exception as e:
                    traceback.print_exc()
                    if data is None or 'error' in data:
                        shutil.move(filepath, os.path.join(dlq_dir, filename))
                        webhook(data)
                        logger.info(f"Exception while processing request [{filename}]: [{e}]. "
                                    f"It has been moved to DLQ.")
                    else:
                        data['error'] = str(e)
                        data['stacktrace'] = ''.join(traceback.format_tb(e.__traceback__))
                        webhook(data)
                        with open(filepath, 'w', encoding='utf-8') as modified_file:
                            json.dump(data, modified_file, indent=2, ensure_ascii=False)
                        logger.info(f"Exception while processing request [{filename}]: [{e}]. "
                                    f"It will be retried later.")


def webhook(request_data):
    try:
        webhook_url = request_data['webhook_url']
        response = requests.post(request_data['webhook_url'], json=request_data)
        response.raise_for_status()
        logger.info(f"Webhook successfully sent to [{webhook_url}]")
    except Exception as e:
        logger.info(f"Exception while sending webhook {json.dumps(request_data)}: [{e}].")
        traceback.print_exc()


if __name__ == "__main__":
    main()
