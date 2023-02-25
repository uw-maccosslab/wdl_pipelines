
import sys
import os
import re
from csv import Sniffer
import pandas as pd
import numpy as np
from math import isclose

def detect_deliminator(fname):
    with open(fname, 'r') as inF:
        dialect = Sniffer().sniff(inF.readline(), delimiters=',\t')
    return dialect.delimiter


class Tsv():
    FP_TOLERANCE = 1e-6

    def __init__(self, fname: str):
        self.fname = fname
        self.delim = detect_deliminator(fname)
        df = pd.read_csv(fname, sep = self.delim)
        str_selection = (df.applymap(type) == str).all().values.tolist()
        int_selection = [str(x).find('float') != 0 for x in df.dtypes.values.tolist()]
        selection = [s or i for s, i in zip(str_selection, int_selection)]
        self.selection = selection
        self.key_cols = df.columns[selection].values.tolist()
        self.float_cols = df.columns[[not x for x in selection]].values.tolist()
        if len(set(self.key_cols + self.float_cols)) != len(self.key_cols + self.float_cols):
            raise RuntimeError(f'Column names in {fname} are not uniquely identified!')
        keys = df[self.key_cols].apply(lambda x: '\t'.join([str(v) for v in x]), axis = 1)
        if len(keys) != len(set(keys)):
            raise RuntimeError(f'String columns in {fname} are not uniquely identified!')
        self.index = {k: np.array(v) for k, v in zip(keys, df[self.float_cols].values)}


    def compare(self, rhs, out = sys.stdout) -> bool:

        # check columns
        # exit immediately if col headers are not the same
        lhs_cols = set(self.float_cols + self.key_cols)
        rhs_cols = set(rhs.float_cols + rhs.key_cols)
        lhs_name = os.path.basename(self.fname)
        rhs_name = os.path.basename(rhs.fname)
        if lhs_name == rhs_name:
            lhs_name = 'lhs'
            rhs_name = 'rhs'
        if lhs_cols != rhs_cols:
            out.write('Column headers differ!\n')
            out.write(f'In common: {lhs_cols.intersection(rhs_cols)}\n')
            out.write(f'Unique to {lhs_name}: {lhs_cols - rhs_cols}\n')
            out.write(f'Unique to {rhs_name}: {rhs_cols - lhs_cols}\n')
            return False
        
        almost_identical = True
        rhs_len = len(rhs.index)
        lhs_len = len(self.index)
        
        if lhs_len != rhs_len:
            almost_identical = False
            if rhs_len > lhs_len:
                longer = lhs_name
                shorter = rhs_name
            else:
                shorter = lhs_name
                longer = rhs_name
            out.write('{} has {} more elements than {}\n'.format(longer, abs(rhs_len - lhs_len), shorter))

        # check keys
        lhs_unique_keys = 0
        rhs_unique_keys = 0
        for k in self.index:
            if k not in rhs.index:
                lhs_unique_keys += 1
        for k in rhs.index:
            if k not in self.index:
                rhs_unique_keys += 1
        for name, count in [(lhs_name, lhs_unique_keys), (rhs_name, rhs_unique_keys)]:
            out.write('There are {} keys unique to {}\n'.format(count, name))
        if lhs_unique_keys + rhs_unique_keys > 0:
            almost_identical = False

        # check floating point numbers
        keys_in_common = 0
        for k, v in self.index.items():
            if k in rhs.index:
                keys_in_common += 1
                if abs(v - rhs.index[k]).max() > self.FP_TOLERANCE:
                    out.write(f'values differ\nrhs\t')
                    out.write('file\t{}'.format('\t'.join(self.key_cols)))
                    out.write('\t{}\n'.format('\t'.join(self.float_cols)))
                    out.write('{}\t{}\n'.format(k, '\t'.join([str(x) for x in v])))
                    out.write('{}\t{}\n'.format(k, '\t'.join([str(x) for x in rhs.index[k]])))
        if keys_in_common == 0:
            out.write('There are no keys in common')
        
        return almost_identical

