
import argparse
import sys
import os
from hashlib import md5

from .submodules import tsv, gct

def md5_sum(fname):
    ''' Get the md5 digest of a file. '''
    file_hash = md5()
    with open(fname, 'rb') as inF:
        while chunk := inF.read(8192):
            file_hash.update(chunk)
    return file_hash.hexdigest()


def find_files(target_files, output_dir):
    if not os.path.isdir(output_dir):
        print(f'"{output_dir}" is not a directory!')
        sys.exit(1)
    sucess = True
    comparisons = dict()
    for file in target_files:
        this_all_good = True

        # look for target files
        if not os.path.isfile(file):
            print(f'Target file "{file}" does not exist!')
            this_all_good = False

        # look for output files
        rhs_file_path = '{}/{}'.format(output_dir, os.path.basename(file))
        if not os.path.isfile(rhs_file_path):
            print(f'Output file "{rhs_file_path}" does not exist!')
            this_all_good = False

        # add to comparisons
        if this_all_good:
            key = os.path.basename(file)
            if key in comparisons:
                print(f'WARN: Duplicate file -> {key}')
            comparisons[key] = (file, rhs_file_path)
        else:
            sucess = False

    if sucess:
        return comparisons
    return None


def compare_tsvs(target_fname, test_fname):
    target = tsv.Tsv()
    target.read(target_fname)
    test = tsv.Tsv()
    test.read(test_fname)
    return target.compare(test)


def compare_gcts(target_fname, test_fname):
    target = gct.Gct()
    target.read(target_fname)
    test = gct.Gct()
    test.read(test_fname)
    return target.compare(test)


def main():
    parser = argparse.ArgumentParser(description='Compare cromwell output for an individual task.')
    parser.add_argument('-e', '--addExactMatch', action='append',
                        help='Add a target file which should match exactly in the cromwell output')
    parser.add_argument('-t', '--addTsv', action='append',
                        help='Add a tsv file should almost match the cromwell output. '
                             'Takes into account floating point error in numeric columns.')
    parser.add_argument('-g', '--addGct', action='append',
                        help='Add a gct file should almost match the cromwell output. '
                             'Takes into account floating point error in numeric columns.')
    parser.add_argument('cromwellExecutionDir',
                        help='')
    args = parser.parse_args()

    print(f'Searching directory:\n{args.cromwellExecutionDir}')
    exact_matches = find_files(args.addExactMatch, args.cromwellExecutionDir) if args.addExactMatch else {}
    tsv_matches = find_files(args.addTsv, args.cromwellExecutionDir) if args.addTsv else {}
    gct_matches = find_files(args.addGct, args.cromwellExecutionDir) if args.addGct else {}
    if exact_matches is None or tsv_matches is None or gct_matches is None:
        sys.exit(1)
    if len(exact_matches) + len(tsv_matches) == 0:
        sys.exit(1)

    matches = 0
    max_len = min(max(len(x) for x in exact_matches), 50)
    for key, value in exact_matches.items():
        lhs_hash = md5_sum(value[0])
        rhs_hash = md5_sum(value[1])
        if lhs_hash == rhs_hash:
            sign = '=='
            matches += 1
        else:
            sign = '!='
        spaces = ' ' * (max_len - len(key))
        print(f'{spaces}{key}: {lhs_hash} {sign} {rhs_hash}')

    aprox_comparisons = [(compare_tsvs, basename, paths) for basename, paths in tsv_matches.items()]
    aprox_comparisons += [(compare_gcts, basename, paths) for basename, paths in gct_matches.items()]
    aprox_matches = 0
    if len(aprox_comparisons) > 0:
        max_len = min(max(len(x[1]) for x in aprox_comparisons), 50)
    for compare_f, basename, paths in aprox_comparisons:
        print(f'\nTesting {basename}')
        if compare_f(paths[0], paths[1]):
            sign = '~'
            aprox_matches += 1
        else:
            sign = '!~'
        spaces = ' ' * (max_len - len(basename))
        print(f'{spaces}{basename}: target {sign} result\n')

    print(f'{matches} of {len(exact_matches)} files matched exactly.')
    print(f'{aprox_matches} of {len(aprox_comparisons)} tsv/gct files matched approximately.')
    if matches != len(exact_matches):
        sys.exit(1)
    if aprox_matches != len(aprox_comparisons):
        sys.exit(1)


if __name__ == '__main__':
    main()

