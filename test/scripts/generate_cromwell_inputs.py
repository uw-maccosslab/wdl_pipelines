
import argparse
import sys
import os
import json

def main():
    parser = argparse.ArgumentParser(description='Replace relative file paths with absolute file paths in cromwell inputs file.')
    parser.add_argument('inputs_template', help='Inputs template with file datatypes marked.')
    parser.add_argument('inputs', help='Inputs file with relative file paths.')
    args = parser.parse_args()
    
    with open(args.inputs_template, 'r') as inF:
        inputs_template = json.load(inF)

    with open(args.inputs, 'r') as inF:
        inputs = json.load(inF)

    # get a list of files variables in input_template and check that they exist in inputs
    file_vars = [k for k, v in inputs_template.items() if v == 'File']
    any_missing = False
    for var in file_vars:
        if var not in inputs:
            any_missing = True
            sys.stderr.write(f'ERROR: Missing required variable {var} in {args.inputs}\n')
    if any_missing:
        sys.exit(1)
    optional_file_vars = [k for k, v in inputs_template.items() if v == 'File? (optional)' and v in inputs]

    # convert relative to absolute paths
    any_missing = False
    for var in file_vars + optional_file_vars:
        inputs[var] = os.path.abspath(os.path.join(os.path.dirname(args.inputs), inputs[var]))
        if not (os.path.isfile(inputs[var]) or os.path.isdir(inputs[var])):
            any_missing = True
            sys.stderr.write(f'ERROR: File "{inputs[var]}" does not exist!\n')
    if any_missing:
        sys.exit(1)

    sys.stdout.write(json.dumps(inputs, indent=4) + '\n')


if __name__ == '__main__':
    main()

