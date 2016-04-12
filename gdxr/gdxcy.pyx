from gdxapi cimport *

import numpy as np
cimport numpy as np

import cython
cimport cython



DEFAULT_GAMS_DIR = "C:/GAMS/win64/24.5"

cdef init_gdx(gdxHandle_t* h_p, char* gams_dir, char* gdx_file, char* msg, int* status_p):
    assert gdxCreateD(h_p, gams_dir, msg, GMS_SSSIZE),"GDX library could not be initialized with '{}'".format(gams_dir)
    assert gdxOpenRead(h_p[0], gdx_file, status_p),"GDX file '{}' could not be opened for reading".format(gdx_file)

cdef get_symbol_info(gdxHandle_t h, char* v_name, int* var_nr_p, int* dim_p, int* symtype_p):
    if gdxFindSymbol(h, v_name, var_nr_p)==0:
        raise Exception("Symbol not found.")
    assert gdxSymbolInfo(h, var_nr_p[0], v_name, dim_p, symtype_p),"Symbol info could not be retrieved for '{}'.".format(v_name)

cdef init_read(gdxHandle_t h, int var_nr, int* nr_recs_p):
    assert gdxDataReadStrStart(h, var_nr, nr_recs_p),"Read could not be initialized."

cdef get_values(v_name,gdx_file,gams_dir,int idx=GMS_VAL_LEVEL):
    cdef:
        gdxHandle_t gdx_h
        int status, var_nr, nr_recs, f_dim, dim, symtype
        char msg[GMS_SSSIZE]
        gdxStrIndex_t strIndex
        gdxStrIndexPtrs_t sp
        gdxValues_t v

    gdx_h = NULL
    init_gdx(&gdx_h, gams_dir, gdx_file, msg, &status)
    get_symbol_info(gdx_h,v_name,&var_nr,&dim,&symtype)

    init_read(gdx_h,var_nr,&nr_recs)
    GDXSTRINDEXPTRS_INIT(strIndex,sp)

    cdef:
        np.ndarray[np.float64_t, ndim=1] out = np.zeros((nr_recs,))
        np.ndarray str_idx = np.empty((nr_recs,dim),dtype=object)
        int i, count = 0

    while gdxDataReadStr(gdx_h, sp, v, &f_dim):
        for i in range(dim):
            str_idx[count,i] = sp[i]
        out[count] = v[idx]
        count += 1
    return str_idx,out

cpdef get_all(v_name,gdx_file,gams_dir=DEFAULT_GAMS_DIR):
    cdef:
        gdxHandle_t gdx_h
        int status, var_nr, nr_recs, f_dim, dim, symtype
        char msg[GMS_SSSIZE]
        gdxStrIndex_t strIndex
        gdxStrIndexPtrs_t sp
        gdxValues_t v

    gdx_h = NULL
    init_gdx(&gdx_h, gams_dir, gdx_file, msg, &status)
    get_symbol_info(gdx_h,v_name,&var_nr,&dim,&symtype)

    init_read(gdx_h,var_nr,&nr_recs)
    GDXSTRINDEXPTRS_INIT(strIndex,sp)

    cdef:
        np.ndarray[np.float64_t, ndim=2] out = np.zeros((nr_recs,GMS_VAL_MAX))
        np.ndarray str_idx = np.empty((nr_recs,dim),dtype=object)
        int i

    count = 0
    while gdxDataReadStr(gdx_h, sp, v, &f_dim):
        for i in range(dim):
            str_idx[count,i] = sp[i]
        for i in range(GMS_VAL_MAX):
            out[count,i] = v[i]
        count += 1

    assert gdxDataReadDone(gdx_h)
    if gdxClose(gdx_h):
        raise Exception('Error closing GDX file.')
    return str_idx,out

cpdef get_level(v_name,gdx_file):
    return get_values(v_name,gdx_file,DEFAULT_GAMS_DIR,GMS_VAL_LEVEL)

cpdef get_marginal(v_name,gdx_file):
    return get_values(v_name,gdx_file,DEFAULT_GAMS_DIR,GMS_VAL_MARGINAL)

cpdef get_level_py(v_name,gdx_file):
    cdef int ret
    import gdxcc as gp

    gdxHandle = gp.new_gdxHandle_tp()
    rc = gp.gdxCreateD(gdxHandle, DEFAULT_GAMS_DIR, gp.GMS_SSSIZE)
    assert rc[0],rc[1]
    assert gp.gdxOpenRead(gdxHandle, gdx_file)[0]

    #ret, fileVersion, producer = gp.gdxFileVersion(gdxHandle)

    ret, symNr = gp.gdxFindSymbol(gdxHandle, v_name)
    ret, symName, dim, symType = gp.gdxSymbolInfo(gdxHandle, symNr)
    ret, nrRecs = gp.gdxDataReadStrStart(gdxHandle, symNr)

    cdef:
        np.ndarray[np.float64_t, ndim=1] out = np.zeros((nrRecs,))
        np.ndarray str_idx = np.empty((nrRecs,dim),dtype=object)
        list elements,values
        int i,afdim

    for i in range(nrRecs):
        ret, elements, values, afdim = gp.gdxDataReadStr(gdxHandle)
        str_idx[i,:] = elements
        out[i] = values[gp.GMS_VAL_LEVEL]

    gp.gdxDataReadDone(gdxHandle)
    gp.gdxClose(gdxHandle)
    return str_idx,out

#print GMS_SSSIZE