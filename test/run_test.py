import gdxr

TEST_GDX_FILE = "Trnsport.gdx"

def test_set():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        j = f['j']
        assert list(j)==['new-york', 'chicago', 'topeka']

if __name__ == '__main__':
    test_set()
