
import pandas as pd
import sys
from io import StringIO
from .tsv import Tsv

class Gct(Tsv):
    def __init__(self):
        self.metadata = {}
        super().__init__()

    def read(self, fname: str):
        self.fname = fname
        self.delim = '\t'

        with open(fname, 'r') as inF:
            version = inF.readline().strip()
            if version != '#1.3':
                raise ValueError(f'{version} is an unknown .gct version!')
            n_rows, n_columns, n_row_meta, n_col_meta = tuple(int(x) for x in inF.readline().strip().split(sep=self.delim))

            # init data string stream and write header row
            header = inF.readline()
            data = StringIO()
            data.write(header)
            header = [x.strip() for x in header.strip().split(sep=self.delim)]
            self.metadata = {h: [] for h in header}
            
            # read metadata
            for _ in range(n_row_meta):
                cells = inF.readline().strip().split(self.delim)
                if len(cells) != len(header):
                    raise ValueError('Number of metadata cells and headers differ!')
                for h, c in zip(header, cells):
                    self.metadata[h].append(c)

            # read data
            for line in inF:
                data.write(line)
            data.seek(0)
            df = pd.read_csv(data, sep='\t')
            self._parse_df(df)

    def compare(self, rhs, out = sys.stdout) -> bool:
        # check metadata. Exit immediately if not the same.
        if len(self.metadata) != len(rhs.metadata):
            out.write('Metadata lengths differ!\n')
            return False
        for lhs_key, rhs_key in zip(self.metadata, rhs.metadata):
            if lhs_key != rhs_key:
                out.write(f'Metadata headers differ!\n{lhs_key} != {rhs_key}')
                return False
            for lhs_value, rhs_value in zip(self.metadata[lhs_key], rhs.metadata[rhs_key]):
                if lhs_value != rhs_value:
                    out.write(f'Metadata values differ!\n{lhs_value} != {rhs_value}')
                    return False

        # check data
        return super().compare(rhs, out)

