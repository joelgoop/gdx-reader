# gdx-reader - Read GDX files fast

`gdx-reader` is a python package to read GDX files (for interaction with GAMS, the General Algebraic Modeling System). To increase performance for large data structures, `gdx-reader` leverages the C API for GDX files distributed with the GAMS installation.


## Dependencies

For `gdx-reader` to work, you need:

- A GAMS installation that is sufficiently recent to ship with a compatible version of the C API (has been tested with 24.5).
- An installation of Python 3.4, 3.5, or 3.6. It will be easiest to use Anaconda, which can be downloaded from https://www.continuum.io/downloads.
- The Python packages `numpy` and `pandas` (these will be automatically installed if `gdx-reader` is installed through Anaconda).


## Installation 

The easiest way is to install with Anaconda. First, download and install the Anaconda Python distribution from https://www.continuum.io/downloads. Then install on the command line (in the Anaconda prompt, or if you have added Anaconda to your PATH, in any command prompt):
```
conda install -c goop gdx-reader
```


## Basic usage

Read a symbol from the GDX file into python, simply use the `GdxFile` object with the index operator:

```python
import gdxr

with gdxr.GdxFile("path/to/file.gdx") as f:
    python_variable = f["symbol_name"]
```

Note that if the symbol is a set, the object returned will be a `numpy.ndarray` with `bytes` objects. They can easily be converted into Python `str` objects with `python_variable.astype(str)`. If the symbol is a parameter, the returned object will be a `pandas.Series`, with a `pandas.MultiIndex` consisting of all set elements as `bytes` objects. Equation and variables are returned as `pandas.DataFrame`s with the set elements as a `MultiIndex` on the rows and the columns being `level`, `marginal`, `lower`, `upper`, and `scale`. Read more about these objects in the [Pandas documentation](http://pandas.pydata.org/pandas-docs/stable/) and the [Numpy documentation](https://docs.scipy.org/doc/numpy/).

To read the symbol with predetermined types for the set elements, use the `get` function and supply tuples containing index names and types through the `idx_names_types` keyword parameter:

```python
import gdxr

with gdxr.GdxFile("path/to/file.gdx") as f:
    python_variable = f.get("symbol_name", idx_names_types=[("country", str), ("timestep", int)])
```

NB: Supplying the type `str` will give a Python `str` object instead of the `bytes` object returned by default.


### GAMS directory not found

If your GAMS installation is not added to your PATH system variable `gdx-reader` will not detect it automatically. You can solve that by adding it to your PATH or supplying it when calling `GdxFile`: `GdxFile("path/to/file.gdx", gams_dir="C:/GAMS/win64/24.5")` (the `gams_dir` argument should point to the main folder where `gams.exe` is located).


## Building the conda package including the `cython` extension on Windows

After installing the Microsoft Visual C++ Build Tools, the following has worked for me:
```bat
call "C:\Program Files (x86)\Microsoft Visual C++ Build Tools\vcbuildtools.bat" amd64
conda build --py <python-version> conda.recipe
```


## Licensing

Copyright (C) 2017 Joel Goop `gdx-reader` is licensed under the GNU General Public License version 3.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.