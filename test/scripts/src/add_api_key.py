
import sys
import json
import argparse

from .submodules.api_key import add_api_key, API_KEY_NAME


def main():
    parser = argparse.ArgumentParser(description='Append api key to workflow inputs file.')
    parser.add_argument('-o', '--ofname', default=None,
                        help='Name of output file. If not specified output is printed to stdout.')
    parser.add_argument('key', help=f'json formated file with a single key value pair: "{API_KEY_NAME}": <key>')
    parser.add_argument('inputs', help='Workflow inputs file.')
    args = parser.parse_args()

    # read inputs
    with open(args.inputs, 'r') as inF:
        inputs = json.load(inF)
    add_api_key(inputs, args.key)

    # write output
    if args.ofname:
        with open(args.ofname, 'w') as outF:
            outF.write(json.dumps(inputs, indent=4) + '\n')
    else:
        sys.stdout.write(json.dumps(inputs, indent=4) + '\n')


if __name__ == '__main__':
    main()

