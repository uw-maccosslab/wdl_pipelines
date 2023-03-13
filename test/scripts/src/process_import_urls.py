
import sys
import os
import argparse
import re


def escape_re(s):
    for char in ('.', '-', '/'):
        s = s.replace(char, rf'\{char}')
    return s


def replace_import_paths(lines, fname, repo_root_url, log_file=None):
    import_line_re = re.compile(r'import\s+"(({})/?([a-zA-Z\-\.\/]+))" as ([\w]+)'.format(escape_re(repo_root_url)))
    
    file_abs_path = os.path.abspath(fname)
    if log_file and fname:
        with open(log_file, 'a') as outF:
            outF.write('\n\n{}\n'.format(' '.join(sys.argv)))
            outF.write(f'\nProcessing {fname}...\n')

    ret = list()
    for line in lines:
        m = import_line_re.search(line)
        if m:
            new_path = f'{file_abs_path}'
            if not os.path.isfile(new_path):
                raise RuntimeError(f'{new_path} is not a file!')
            new_line = f'import "{m.group(3)}" as {m.group(4)}'
            if log_file:
                with open(log_file, 'a') as outF:
                    outF.write(f'Replaced\n\t{line} ->\n\t{new_line}\n')
        else:
            new_line = line
        ret.append(new_line)
    return ret


def write_lines(out, lines):
    for line in lines:
        out.write(f'{line}\n')


def main():
    parser = argparse.ArgumentParser(description='Replace url imports in workflow scripts with local '
                                                 'file imports to make testing easier.')
    parser.add_argument('--logFile', default=None,
                        help='Path to log file. If not set no log information is written')
    parser.add_argument('--inPlace', default=False, action='store_true',
                        help='Should url replacements be done in place? '
                             'If not set, the processed wdl is printed to stdout.')
    parser.add_argument('repo_root_url',
                        help='The root url of the repo where the workflow is stored.')
    parser.add_argument('wdl_file', help='The wdl file to process')
    args = parser.parse_args()

    with open(args.wdl_file, 'r') as inF:
        lines = [x.rstrip() for x in inF.readlines()]

    proc_lines = replace_import_paths(lines, args.wdl_file, args.repo_root_url, args.logFile)

    if args.inPlace:
        with open(args.wdl_file, 'w') as outF:
            write_lines(outF, proc_lines)
    else:
        write_lines(sys.stdout, proc_lines)

if __name__ == '__main__':
    main()

