from gdxapi cimport *

cimport numpy as np
import numpy as np

import pandas as pd

import cython
cimport cython

cdef replace_gams_values(np.ndarray out):
    out[out==GMS_SV_EPS] = 0
    out[out==GMS_SV_MINF] = -np.inf
    out[out==GMS_SV_PINF] = np.inf
    out[out==GMS_SV_UNDEF] = np.nan
    out[out==GMS_SV_NA] = np.nan
    return out

cdef construct_index(np.ndarray str_idx, names_types=None):
    if names_types is None:
        if str_idx.shape[1] < 1:
            idx = str_idx[:]
        elif str_idx.shape[1] > 1:
            idx = pd.MultiIndex.from_arrays(str_idx.T)
        else:
            idx = str_idx[:,0]
    else:
        if str_idx.shape[1] < 1:
            n,t = names_types
            idx = pd.Index(str_idx[:].astype(t),name=n)
        elif str_idx.shape[1] > 1:
            idx_list = []
            names = []
            for i,(n,t) in enumerate(names_types):
                idx_list.append(str_idx[:,i].astype(t))
                names.append(n)
            idx = pd.MultiIndex.from_arrays(idx_list,names=names)
        else:
            n,t = names_types
            idx = pd.Index(str_idx[:,0].astype(t),name=n)

    return idx

cdef class CFile:
    cdef:
        gdxHandle_t gdx_h
        int status
        char msg[GMS_SSSIZE]

    def __cinit__(self,gdx_file,gams_dir):
        self.gdx_h = NULL
        assert gdxCreateD(&self.gdx_h, gams_dir, self.msg, GMS_SSSIZE),"GDX library could not be initialized with '{}'".format(gams_dir)
        assert gdxOpenRead(self.gdx_h, gdx_file, &self.status),"GDX file '{}' could not be opened for reading".format(gdx_file)

    cpdef CSymbol get_symbol(self,v_name):
        cdef int var_nr, dim, symtype

        # Locate symbol
        if gdxFindSymbol(self.gdx_h, v_name, &var_nr)==0:
            raise KeyError("Symbol '{}' not found.".format(v_name))
        # Get symbol information
        assert gdxSymbolInfo(self.gdx_h, var_nr, v_name, &dim, &symtype),"Symbol info could not be retrieved for '{}'.".format(v_name)

        if symtype==GMS_DT_VAR:
            return CVariable(self,v_name,var_nr,dim)
        if symtype==GMS_DT_EQU:
            return CEquation(self,v_name,var_nr,dim)
        if symtype==GMS_DT_PAR:
            return CParameter(self,v_name,var_nr,dim)
        if symtype==GMS_DT_SET:
            return CSet(self,v_name,var_nr,dim)
        if symtype==GMS_DT_ALIAS:
            return CAlias(self,v_name,var_nr,dim)

    def __del__(self):
        if gdxClose(self.gdx_h):
            raise Exception('Error closing GDX file.')


cdef class CSymbol:
    cdef:
        int var_nr, nr_recs, f_dim, dim
        CFile f
        gdxStrIndex_t strIndex
        gdxStrIndexPtrs_t sp
        gdxValues_t v
        str name

    def __cinit__(self,c_file,v_name,var_nr,dim):
        self.f = c_file
        self.name = v_name
        self.dim = dim
        self.var_nr = var_nr

    cdef init_read(self):
        # Init reading and get number of records
        assert gdxDataReadStrStart(self.f.gdx_h, self.var_nr, &self.nr_recs),"Read could not be initialized."
        # Initialize reading and pointers for index
        GDXSTRINDEXPTRS_INIT(self.strIndex, self.sp)



cdef class CVarOrEqu(CSymbol):
    cpdef read(self,names_types=None):
        self.init_read()
        if self.dim==0 and gdxDataReadStr(self.f.gdx_h, self.sp, self.v, &self.f_dim):
            vals = replace_gams_values(np.array(self.v))
            return pd.Series(vals,index=['level','marginal','lower','upper','scale'])

        cdef:
            np.ndarray[np.float64_t, ndim=2] out = np.zeros((self.nr_recs,GMS_VAL_MAX))
            np.ndarray[object, ndim=2] str_idx = np.empty((self.nr_recs, self.dim),dtype=object)
            int i,count = 0

        while gdxDataReadStr(self.f.gdx_h, self.sp, self.v, &self.f_dim):
            for i in range(self.dim):
                str_idx[count,i] = self.sp[i]
            for i in range(GMS_VAL_MAX):
                out[count,i] = self.v[i]
            count += 1

        assert gdxDataReadDone(self.f.gdx_h),"'gdxDataReadDone' failed."
        idx = construct_index(str_idx, names_types)
        out = replace_gams_values(out)
        return pd.DataFrame(out,index=idx,columns=['level','marginal','lower','upper','scale'])

cdef class CParameter(CSymbol):
    cpdef read(self, names_types=None):
        self.init_read()
        if self.dim==0 and gdxDataReadStr(self.f.gdx_h, self.sp, self.v, &self.f_dim):
            vals = replace_gams_values(np.array(self.v))
            return vals[0]

        cdef:
            np.ndarray[np.float64_t, ndim=1] out = np.zeros((self.nr_recs,))
            np.ndarray[object, ndim=2] str_idx = np.empty((self.nr_recs, self.dim),dtype=object)
            int i,count = 0

        while gdxDataReadStr(self.f.gdx_h, self.sp, self.v, &self.f_dim):
            for i in range(self.dim):
                str_idx[count,i] = self.sp[i]
            out[count] = self.v[0]
            count += 1

        assert gdxDataReadDone(self.f.gdx_h),"'gdxDataReadDone' failed."
        idx = construct_index(str_idx, names_types)
        out = replace_gams_values(out)
        return pd.Series(out,index=idx)

cdef class CVariable(CVarOrEqu):
    pass
cdef class CEquation(CVarOrEqu):
    pass
    
cdef class CSet(CSymbol):
    cpdef read(self, names_types=None):
        self.init_read()
        cdef:
            np.ndarray[object, ndim=2] elems = np.empty((self.nr_recs, self.dim),dtype=object)
            int i,count = 0

        while gdxDataReadStr(self.f.gdx_h, self.sp, self.v, &self.f_dim):
            for i in range(self.dim):
                elems[count,i] = self.sp[i]
            count += 1

        assert gdxDataReadDone(self.f.gdx_h),"'gdxDataReadDone' failed."
        if self.dim==1:
            return elems[:,0]
        return elems

cdef class CAlias(CSet):
    pass