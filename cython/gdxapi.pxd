cdef extern from "gdxcc.h":
    enum: GMS_SSSIZE

    enum: GMS_DT_VAR
    enum: GMS_DT_SET
    enum: GMS_DT_PAR
    enum: GMS_DT_VAR
    enum: GMS_DT_EQU
    enum: GMS_DT_ALIAS

    double GMS_SV_UNDEF
    double GMS_SV_NA
    double GMS_SV_PINF
    double GMS_SV_MINF
    double GMS_SV_EPS

    enum: GMS_MAX_INDEX_DIM

    enum: GMS_VAL_LEVEL
    enum: GMS_VAL_MARGINAL
    enum: GMS_VAL_LOWER
    enum: GMS_VAL_UPPER
    enum: GMS_VAL_SCALE
    enum: GMS_VAL_MAX

    ctypedef struct gdxRec
    ctypedef gdxRec *gdxHandle_t
    ctypedef char gdxStrIndex_t[GMS_MAX_INDEX_DIM][GMS_SSSIZE]
    ctypedef char *gdxStrIndexPtrs_t[GMS_MAX_INDEX_DIM]
    ctypedef double gdxValues_t[GMS_VAL_MAX]
    void GDXSTRINDEXPTRS_INIT(gdxStrIndex_t idx,gdxStrIndexPtrs_t idxPtrs)

    int gdxCreateD (gdxHandle_t *pgdx, const char *dirName, char *msgBuf, int msgBufLen)
    int gdxDataReadStr (gdxHandle_t pgdx, char *KeyStr[], double Values[], int *DimFrst)
    int gdxDataReadStrStart (gdxHandle_t pgdx, int SyNr, int *NrRecs)
    int gdxOpenRead (gdxHandle_t pgdx, const char *FileName, int *ErrNr)
    int gdxDataReadDone (gdxHandle_t pgdx)
    int gdxFindSymbol (gdxHandle_t pgdx, const char *SyId, int *SyNr)
    int gdxSymbolInfo (gdxHandle_t pgdx, int SyNr, char *SyId, int *Dimen, int *Typ)
    int gdxClose (gdxHandle_t pgdx)