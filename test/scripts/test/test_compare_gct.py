
import sys
import unittest
import os
from io import StringIO

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from context import src, DATA_DIR
from src.submodules.gct import Gct


class TestGct(unittest.TestCase):

    def test_compare_true(self):
        lhs = Gct()
        rhs = Gct()
        lhs.read(f'{DATA_DIR}/lhs.true.gct')
        rhs.read(f'{DATA_DIR}/rhs.true.gct')
        out = StringIO()
        # out = sys.stdout
        self.assertTrue(lhs.compare(rhs, out))
        # out.seek(0)
        # with open('output.txt', 'w') as outF:
        #     outF.write(out.read())

    def test_compare_different_metadata(self):
        lhs = Gct()
        rhs = Gct()
        lhs.read(f'{DATA_DIR}/lhs.failing.metadata_order.gct')
        rhs.read(f'{DATA_DIR}/rhs.failing.metadata_order.gct')
        # out = sys.stdout
        out = StringIO()
        self.assertFalse(lhs.compare(rhs, out))


if __name__ == '__main__':
    unittest.main(verbosity=2)

