
import sys
import unittest
import os
from io import StringIO

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from context import src, DATA_DIR
from src.submodules.tsv import Tsv


class TestTsv(unittest.TestCase):

    def test_compare_different_row_number(self):
        lhs = Tsv()
        rhs = Tsv()
        lhs.read(f'{DATA_DIR}/lhs.failing.row_nums.tsv')
        rhs.read(f'{DATA_DIR}/rhs.failing.row_nums.tsv')
        # out = StringIO()
        out = sys.stdout
        self.assertFalse(lhs.compare(rhs, out))
        # out.seek(0)
        # with open('output.txt', 'w') as outF:
        #     outF.write(out.read())


if __name__ == '__main__':
    unittest.main(verbosity=2)

