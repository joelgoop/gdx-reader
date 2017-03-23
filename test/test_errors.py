import gdxr
import pytest

TEST_GDX_FILE = "test/data/Trnsport.gdx"


def test_unknown_file():
    with pytest.raises(FileNotFoundError):
        gdxr.GdxFile("unknownfile.gdx")

def test_unknown_symbol():
    with pytest.raises(KeyError):
        with gdxr.GdxFile(TEST_GDX_FILE) as f:
            f['unknownsymbol']