import os
import numpy as np

try:
    from setuptools import setup
    from setuptools import Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension

from Cython.Build import cythonize

apidir = 'C:/GAMS/win64/24.5/apifiles/C/api'

ext_modules = [Extension(
    "gdxr.gdxcy",
    ["cython/gdxcy.pyx", os.path.join(apidir, "gdxcc.c")],
    include_dirs=[apidir, np.get_include()]
)]

setup(
    name='gdx-reader',
    version='0.2.7',
    packages=['gdxr'],
    ext_modules=cythonize(ext_modules),
    url='https://github.com/joelgoop/gdx-reader',
    author='Joel Goop',
    author_email='joel.goop@chalmers.se',
    license='GPLv3',
    setup_requires=['pytest-runner'],
    tests_require=['pytest']
)
