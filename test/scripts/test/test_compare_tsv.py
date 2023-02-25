
import unittest
import re
import os
import tempfile
from io import StringIO

from .context import src, DATA_DIR
from src.submodules.tsv import Tsv


class TestTsv(unittest.TestCase):

    # path to test fasta file
    # TEST_FASTA = f'{DATA_DIR}/test.fasta'

    def test_compare_different_row_number(self):
        lhs = Tsv(f'{DATA_DIR}/lhs.tsv')
        rhs = Tsv(f'{DATA_DIR}/rhs.tsv')
        out = StringIO()
        self.assertFalse(lhs.compare(rhs, out))
        out.seek(0)
        with open('output.txt', 'w') as outF:
            outF.write(out.read())

if __name__ == '__main__':
    unittest.main(verbosity=2)

