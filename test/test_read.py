import gdxr
import pytest
import numpy as np

TEST_GDX_FILE = "test/data/Trnsport.gdx"


def test_set():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        j = f['j']

    assert list(j) == [b'new-york', b'chicago', b'topeka']


def test_equ():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        supply = f['supply']

    assert (supply.values == np.array([[ 350.,    0.,  -np.inf,  350.,    1.],
       [ 550.,    0.,  -np.inf,  600.,    1.]])).all()
    assert (supply.columns == 
        ['level', 'marginal', 'lower', 'upper', 'scale']).all()
    assert (supply.index == [b'seattle', b'san-diego']).all()


def test_par():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        d = f['d']

    assert (d.values == np.array([2.5, 1.7, 1.8, 2.5, 1.8, 1.4])).all()
    didx = [('seattle', 'new-york'), ('seattle', 'chicago'),
        ('seattle', 'topeka'), ('san-diego', 'new-york'),
        ('san-diego', 'chicago'), ('san-diego', 'topeka')]
    assert (list(d.index) == didx)


def test_var():
    with gdxr.GdxFile(TEST_GDX_FILE) as f:
        x = f['x'] 

    xvals = np.array([[ 50.0, 0.0, 0.0, np.inf, 1.0 ],
        [ 300.0, 0.0, 0.0, np.inf, 1.0 ],
        [ 0.0, 3.6e-2, 0.0, np.inf, 1.0 ],
        [ 275.0, 0.0, 0.0, np.inf, 1.0 ],
        [ 0.0, 9e-3, 0.0, np.inf, 1.0 ],
        [ 275.0, 0.0, 0.0, np.inf, 1.0 ]])
    print(x.values - xvals)
    xidx = [(x.encode('utf8'), y.encode('utf8')) for x,y in 
            [
                ('seattle', 'new-york'), ('seattle', 'chicago'),
                ('seattle', 'topeka'), ('san-diego', 'new-york'),
                ('san-diego', 'chicago'), ('san-diego', 'topeka')
            ]
        ]
    assert np.isclose(x.values, xvals, equal_nan=True).all()
    assert (x.columns == ['level', 'marginal', 'lower', 'upper', 'scale']).all()
    assert (list(x.index) == xidx)   

if __name__ == '__main__':
    test_set()
    test_equ()
    test_par()
    test_var()