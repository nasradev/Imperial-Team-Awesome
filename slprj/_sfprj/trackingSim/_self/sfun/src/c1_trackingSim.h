#ifndef __c1_trackingSim_h__
#define __c1_trackingSim_h__

/* Include files */
#include "sf_runtime/sfc_sf.h"
#include "sf_runtime/sfc_mex.h"
#include "rtwtypes.h"
#include "multiword_types.h"

/* Type Definitions */
#ifndef typedef_SFc1_trackingSimInstanceStruct
#define typedef_SFc1_trackingSimInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c1_sfEvent;
  boolean_T c1_doneDoubleBufferReInit;
  uint8_T c1_is_active_c1_trackingSim;
  real_T (*c1_dots)[8];
  real_T (*c1_m0)[3];
  real_T (*c1_hat_s)[4];
  real_T (*c1_m1)[3];
  real_T (*c1_s)[4];
  real_T *c1_t;
  real_T (*c1_x)[12];
  real_T (*c1_k)[12];
  real_T *c1_a;
} SFc1_trackingSimInstanceStruct;

#endif                                 /*typedef_SFc1_trackingSimInstanceStruct*/

/* Named Constants */

/* Variable Declarations */
extern struct SfDebugInstanceStruct *sfGlobalDebugInstanceStruct;

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c1_trackingSim_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c1_trackingSim_get_check_sum(mxArray *plhs[]);
extern void c1_trackingSim_method_dispatcher(SimStruct *S, int_T method, void
  *data);

#endif
