import gdxr
import pytest


def test_unknown_file():
    with pytest.raises(FileNotFoundError):
        gdxr.GdxFile("unknownfile.gdx")
