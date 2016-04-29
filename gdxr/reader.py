from .gdxcy import CFile


class GamsDirNotFoundException(Exception):
    pass


class GdxFile(object):
    """
    Reader object for GDX file.
    """

    def __init__(self, path, gams_dir=None):
        self.path = path
        self.gams_dir = gams_dir if gams_dir is not None \
            else self.find_gams_dir()
        self._c_file = CFile(path, self.gams_dir)
        self._symbols = {}

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        return False

    def __getitem__(self, key):
        try:
            return self._symbols[key]
        except KeyError:
            self._symbols[key] = self._get_symbol(key)
            return self._symbols[key]

    def _get_symbol(self, key, idx_names_types=None):
        c_symbol = self._c_file.get_symbol(key)
        return c_symbol.read(idx_names_types)

    def get(self, key, idx_names_types=None):
        return self._get_symbol(key, idx_names_types)

    @staticmethod
    def find_gams_dir():
        from distutils.spawn import find_executable
        import os

        try:
            gams_exe = find_executable('gams')
            return os.path.dirname(gams_exe)
        except TypeError:
            raise GamsDirNotFoundException(
                "Gams directory could not be located."
                " Add to PATH for automatic detection."
            )
