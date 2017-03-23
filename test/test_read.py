import gdxr
import pytest

TEST_GDX_FILE = "test/data/Trnsport.gdx"

def test_set():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        j = f['j']

    assert list(j)==[b'new-york', b'chicago', b'topeka']

def test_equ():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        supply = f['supply']

    assert list(j)==[b'new-york', b'chicago', b'topeka']

if __name__ == '__main__':
    test_set()