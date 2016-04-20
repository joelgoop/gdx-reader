# gdx-reader - Read GDX files fast

## Installation 
The easiest way is to install with Anaconda:
```
conda install -c https://conda.anaconda.org/goop gdx-reader
```

## Building the conda package including the `cython` extension
On Windows the following has worked for me:
```bat
call "C:\Program Files (x86)\Microsoft Visual C++ Build Tools\vcbuildtools.bat" amd64
conda build --py <python-version> conda.recipe
```