#!/usr/bin/env python3

import argparse
import csv
import sys


def detect_dialect(fname):
    with open(fname, 'r') as inF:
        dialect = csv.Sniffer().sniff(inF.readline(), delimiters=',\t')
    return dialect


class Tsv():
    def __init__(self):
        self.data = dict()
        self.headers = dict()
        self.locator_to_name = dict()


    def read(self, fname: str, names_from: str, name_path_from: str, values_from: str):
        duplicates = dict()
        locator_to_name = set()
        with open(fname, 'r') as inF:
            reader = csv.reader(inF, dialect=detect_dialect(fname))

            # process header row
            self.headers = {cell: i for i, cell in enumerate(next(reader))}
            for col in [names_from, values_from, name_path_from]:
                if col not in self.headers:
                    raise RuntimeError(f'Missing required column "{col}" in {fname}')
            data_cols = [i for k, i in self.headers.items() if k not in (names_from, values_from, name_path_from)]
            names_from_i = self.headers[names_from]
            values_from_i = self.headers[values_from]
            names_path_from_i = self.headers[name_path_from]

            for row in reader:
                keys = tuple(row[i] for i in data_cols)
                if keys not in self.data:
                    self.data[keys] = dict()

                # record duplicate keys (if any)
                if row[names_from_i] in self.data[keys]:
                    if keys not in duplicates:
                        duplicates[keys] = set()
                    duplicates[keys].add((row[names_from_i], row[values_from_i]))
                    duplicates[keys].add((row[names_from_i], self.data[keys][row[names_from_i]]))

                locator_to_name.add((row[names_from_i], row[names_path_from_i]))

                self.data[keys][row[names_from_i]] = row[values_from_i]
        
        # check that there wern't any duplicate elements recorded
        all_good = True
        if len(duplicates) > 0:
            sys.stderr.write(f'ERROR: There were {len(duplicates)} duplicate elements!\n')
            for duplicate in duplicates:
                sys.stderr.write(f'{duplicate}\n')
            all_good = False
        
        # populate self.locator_to_name
        for name, locator in locator_to_name:
            if locator not in self.locator_to_name:
                self.locator_to_name[locator] = name
            else:
                if self.locator_to_name[locator] != name:
                    sys.stderr.write(f'Non unique name to locator mapping: {locator} -> {name}\n')
                    all_good = False
        
        return all_good


def main():
    parser = argparse.ArgumentParser(description='Convert easy to use long formated .tsv files into the difficult to use gct format.')
    parser.add_argument('--namesFrom', default='ReplicateName',
                        help='Column to get column names from.')
    parser.add_argument('--namePathFrom', default='ReplicateLocator',
                        help='The element locator that links elements to the annotation file.')
    parser.add_argument('--valuesFrom', default='ProteinAbundance',
                        help='Column to get values from.')
    parser.add_argument('tsv', help='Long formated .tsv file')
    parser.add_argument('annotations', help='Annotations file corresponding to `tsv`.')
    args = parser.parse_args()

    tsv = Tsv()
    tsv.read(args.tsv, args.namesFrom, args.namePathFrom, args.valuesFrom)


if __name__ == '__main__':
    main()
