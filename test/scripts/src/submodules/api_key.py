
import json
import re
from typing import Dict

API_KEY_NAME = 'panorama_api_key'


def add_api_key(inputs: Dict, key_file: str):
    # read key
    with open(key_file, 'r') as inF:
        key = json.load(inF)
    if len(key) != 1 or API_KEY_NAME not in key:
        raise RuntimeError('Invalid workflow key file!')

    # read inputs
    workflow_names = set()
    for var in inputs:
        m = re.search(r'^([a-zA-Z0-9_\-]+)\.', var)
        if not m:
            raise RuntimeError(f'Could not parse workflow name from variable: "{var}"')
        workflow_names.add(m.group(1))
    if len(workflow_names) != 1:
        raise RuntimeError('Could not determine workflow name!')

    inputs[f'{workflow_names.pop()}.{API_KEY_NAME}'] = key[API_KEY_NAME]

