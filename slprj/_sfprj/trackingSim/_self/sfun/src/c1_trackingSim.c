/* Include files */

#include "trackingSim_sfun.h"
#include "c1_trackingSim.h"
#include <math.h>
#include "mwmathutil.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "trackingSim_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c_with_debugger(S, sfGlobalDebugInstanceStruct);

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization);
static void chart_debug_initialize_data_addresses(SimStruct *S);
static const mxArray* sf_opaque_get_hover_data_for_msg(void *chartInstance,
  int32_T msgSSID);

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static real_T _sfTime_;
static const char * c1_debug_family_names[12] = { "J", "nargin", "nargout",
  "dots", "m0", "m1", "s", "t", "x", "k", "a", "hat_s" };

static const char * c1_b_debug_family_names[220] = { "k11", "k12", "k13", "k14",
  "k21", "k22", "k23", "k24", "k31", "k32", "k33", "k34", "m0x", "m0y", "m0z",
  "m1x", "m1y", "m1z", "s1", "s2", "s3", "s4", "x1", "x3", "x5", "t2", "t3",
  "t4", "t5", "t6", "t7", "t8", "t17", "t9", "t10", "t11", "t12", "t13", "t14",
  "t15", "t16", "t18", "t29", "t19", "t20", "t21", "t22", "t23", "t30", "t24",
  "t25", "t26", "t27", "t28", "t31", "t32", "t33", "t43", "t34", "t35", "t36",
  "t37", "t38", "t42", "t39", "t40", "t41", "t44", "t45", "t46", "t47", "t48",
  "t49", "t117", "t50", "t51", "t52", "t53", "t54", "t55", "t56", "t79", "t57",
  "t58", "t59", "t81", "t60", "t61", "t62", "t83", "t63", "t64", "t69", "t65",
  "t66", "t67", "t68", "t70", "t77", "t71", "t72", "t78", "t73", "t74", "t75",
  "t76", "t80", "t82", "t130", "t84", "t85", "t86", "t87", "t88", "t89", "t90",
  "t167", "t91", "t92", "t93", "t94", "t95", "t96", "t97", "t153", "t98", "t99",
  "t100", "t101", "t102", "t103", "t104", "t105", "t107", "t106", "t108", "t109",
  "t115", "t110", "t111", "t112", "t113", "t121", "t114", "t116", "t118", "t119",
  "t120", "t122", "t123", "t124", "t125", "t126", "t127", "t144", "t128", "t129",
  "t131", "t132", "t133", "t134", "t135", "t136", "t137", "t138", "t139", "t140",
  "t141", "t142", "t143", "t145", "t146", "t147", "t148", "t149", "t150", "t151",
  "t152", "t154", "t155", "t156", "t157", "t158", "t159", "t160", "t162", "t161",
  "t163", "t164", "t165", "t166", "t168", "t169", "t170", "t171", "t172", "t173",
  "t174", "t175", "t176", "t177", "t178", "t179", "t180", "t181", "t182", "t183",
  "t184", "t185", "t186", "nargin", "nargout", "a", "k", "m0", "m1", "s", "t",
  "x", "Jac1" };

/* Function Declarations */
static void initialize_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void initialize_params_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void enable_c1_trackingSim(SFc1_trackingSimInstanceStruct *chartInstance);
static void disable_c1_trackingSim(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_update_debugger_state_c1_trackingSim
  (SFc1_trackingSimInstanceStruct *chartInstance);
static const mxArray *get_sim_state_c1_trackingSim
  (SFc1_trackingSimInstanceStruct *chartInstance);
static void set_sim_state_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_st);
static void finalize_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void sf_gateway_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void mdl_start_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void initSimStructsc1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance);
static void c1_Jac1(SFc1_trackingSimInstanceStruct *chartInstance, real_T c1_b_a,
                    real_T c1_b_k[12], real_T c1_b_m0[3], real_T c1_b_m1[3],
                    real_T c1_b_s[4], real_T c1_b_t, real_T c1_b_x[12], real_T
                    c1_b_Jac1[32]);
static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber);
static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData);
static void c1_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_b_hat_s, const char_T *c1_identifier, real_T c1_y[4]);
static void c1_b_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[4]);
static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_d_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_e_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_f_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static real_T c1_c_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_g_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static void c1_d_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[32]);
static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static void c1_e_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[12]);
static void c1_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static void c1_f_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[3]);
static void c1_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static void c1_g_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[12]);
static void c1_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static real_T c1_cos(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x);
static real_T c1_sin(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x);
static int32_T c1_local_rank(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_A[32]);
static boolean_T c1_isfinite(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_b_x);
static void c1_error(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_xzsvdc(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_A[32], real_T c1_S[4]);
static void c1_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static real_T c1_xnrm2(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[32], int32_T c1_ix0);
static real_T c1_abs(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x);
static void c1_realmin(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_eml_realmin(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_check_forloop_overflow_error(SFc1_trackingSimInstanceStruct
  *chartInstance, boolean_T c1_overflow);
static void c1_eps(SFc1_trackingSimInstanceStruct *chartInstance);
static real_T c1_xdotc(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[32], int32_T c1_iy0);
static real_T c1_xdot(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
                      c1_n, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[32],
                      int32_T c1_iy0);
static void c1_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T c1_n,
                     real_T c1_b_a, int32_T c1_ix0, real_T c1_y[32], int32_T
                     c1_iy0, real_T c1_b_y[32]);
static real_T c1_b_xnrm2(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[4], int32_T c1_ix0);
static void c1_b_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_b_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[8],
  int32_T c1_iy0, real_T c1_b_y[8]);
static void c1_c_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[8], int32_T c1_ix0, real_T c1_y[32],
  int32_T c1_iy0, real_T c1_b_y[32]);
static void c1_c_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_dimagree(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_b_error(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_xrotg(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_a, real_T c1_b, real_T *c1_c_a, real_T *c1_b_b, real_T
                     *c1_c, real_T *c1_b_s);
static real_T c1_sqrt(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x);
static void c1_c_error(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_d_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static real_T c1_eml_extremum(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_b_x[5]);
static void c1_pinv(SFc1_trackingSimInstanceStruct *chartInstance, real_T c1_A
                    [32], real_T c1_X[32]);
static void c1_b_xzsvdc(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_A[32], real_T c1_U[32], real_T c1_S[4], real_T c1_V[16]);
static real_T c1_b_xdotc(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0);
static real_T c1_b_xdot(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0);
static void c1_d_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0, real_T
  c1_b_y[16]);
static void c1_e_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_c_x[32]);
static void c1_b_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_c_x[16]);
static void c1_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                    c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                    real_T c1_b_s, real_T c1_c_x[16]);
static void c1_b_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s, real_T c1_c_x[32]);
static void c1_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c_x
                     [16]);
static void c1_b_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c_x[32]);
static void c1_xgemm(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
                     c1_b_k, real_T c1_A[16], real_T c1_B[32], real_T c1_C[32],
                     real_T c1_b_C[32]);
static void c1_f_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static void c1_g_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance);
static const mxArray *c1_h_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static int32_T c1_h_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_g_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static uint8_T c1_i_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_b_is_active_c1_trackingSim, const char_T
  *c1_identifier);
static uint8_T c1_j_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_b_cos(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     *c1_b_x);
static void c1_b_sin(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     *c1_b_x);
static void c1_e_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[32], int32_T c1_iy0);
static void c1_f_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[8],
  int32_T c1_iy0);
static void c1_g_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[8], int32_T c1_ix0, real_T c1_y[32],
  int32_T c1_iy0);
static void c1_b_xrotg(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  *c1_b_a, real_T *c1_b, real_T *c1_c, real_T *c1_b_s);
static void c1_b_sqrt(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      *c1_b_x);
static void c1_h_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0);
static void c1_c_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[32], int32_T c1_ix0);
static void c1_d_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[16], int32_T c1_ix0);
static void c1_c_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s);
static void c1_d_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s);
static void c1_c_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0);
static void c1_d_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0);
static void c1_b_xgemm(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_b_k, real_T c1_A[16], real_T c1_B[32], real_T c1_C[32]);
static void init_dsm_address_info(SFc1_trackingSimInstanceStruct *chartInstance);
static void init_simulink_io_address(SFc1_trackingSimInstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  if (sf_is_first_init_cond(chartInstance->S)) {
    initSimStructsc1_trackingSim(chartInstance);
    chart_debug_initialize_data_addresses(chartInstance->S);
  }

  chartInstance->c1_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c1_is_active_c1_trackingSim = 0U;
}

static void initialize_params_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static void enable_c1_trackingSim(SFc1_trackingSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c1_trackingSim(SFc1_trackingSimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c1_update_debugger_state_c1_trackingSim
  (SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c1_trackingSim
  (SFc1_trackingSimInstanceStruct *chartInstance)
{
  const mxArray *c1_st;
  const mxArray *c1_y = NULL;
  const mxArray *c1_b_y = NULL;
  uint8_T c1_hoistedGlobal;
  uint8_T c1_u;
  const mxArray *c1_c_y = NULL;
  c1_st = NULL;
  c1_st = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_createcellmatrix(2, 1), false);
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", *chartInstance->c1_hat_s, 0, 0U, 1U,
    0U, 1, 4), false);
  sf_mex_setcell(c1_y, 0, c1_b_y);
  c1_hoistedGlobal = chartInstance->c1_is_active_c1_trackingSim;
  c1_u = c1_hoistedGlobal;
  c1_c_y = NULL;
  sf_mex_assign(&c1_c_y, sf_mex_create("y", &c1_u, 3, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 1, c1_c_y);
  sf_mex_assign(&c1_st, c1_y, false);
  return c1_st;
}

static void set_sim_state_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_st)
{
  const mxArray *c1_u;
  real_T c1_dv0[4];
  int32_T c1_i0;
  chartInstance->c1_doneDoubleBufferReInit = true;
  c1_u = sf_mex_dup(c1_st);
  c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell("hat_s", c1_u, 0)),
                      "hat_s", c1_dv0);
  for (c1_i0 = 0; c1_i0 < 4; c1_i0++) {
    (*chartInstance->c1_hat_s)[c1_i0] = c1_dv0[c1_i0];
  }

  chartInstance->c1_is_active_c1_trackingSim = c1_i_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell("is_active_c1_trackingSim", c1_u,
       1)), "is_active_c1_trackingSim");
  sf_mex_destroy(&c1_u);
  c1_update_debugger_state_c1_trackingSim(chartInstance);
  sf_mex_destroy(&c1_st);
}

static void finalize_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  int32_T c1_i1;
  int32_T c1_i2;
  int32_T c1_i3;
  int32_T c1_i4;
  int32_T c1_i5;
  int32_T c1_i6;
  real_T c1_hoistedGlobal;
  real_T c1_b_hoistedGlobal;
  int32_T c1_i7;
  int32_T c1_i8;
  real_T c1_b_dots[8];
  int32_T c1_i9;
  real_T c1_b_m0[3];
  int32_T c1_i10;
  real_T c1_b_m1[3];
  real_T c1_b_t;
  real_T c1_b_s[4];
  int32_T c1_i11;
  int32_T c1_i12;
  real_T c1_b_x[12];
  real_T c1_b_a;
  real_T c1_b_k[12];
  uint32_T c1_debug_family_var_map[12];
  real_T c1_J[32];
  real_T c1_nargin = 8.0;
  real_T c1_nargout = 1.0;
  real_T c1_b_hat_s[4];
  int32_T c1_i13;
  int32_T c1_i14;
  real_T c1_c_k[12];
  int32_T c1_i15;
  real_T c1_c_m0[3];
  int32_T c1_i16;
  real_T c1_c_m1[3];
  int32_T c1_i17;
  real_T c1_c_s[4];
  real_T c1_c_x[12];
  real_T c1_dv1[32];
  int32_T c1_i18;
  int32_T c1_i19;
  int32_T c1_irank;
  real_T c1_varargin_1[32];
  real_T c1_r;
  real_T c1_u;
  const mxArray *c1_y = NULL;
  int32_T c1_i20;
  real_T c1_b_J[32];
  real_T c1_c_a[32];
  int32_T c1_i21;
  int32_T c1_i22;
  real_T c1_b[8];
  int32_T c1_i23;
  int32_T c1_i24;
  int32_T c1_i25;
  real_T c1_C[4];
  int32_T c1_i26;
  int32_T c1_i27;
  int32_T c1_i28;
  int32_T c1_i29;
  int32_T c1_i30;
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  _SFD_DATA_RANGE_CHECK(*chartInstance->c1_a, 7U, 1U, 0U,
                        chartInstance->c1_sfEvent, false);
  for (c1_i1 = 0; c1_i1 < 12; c1_i1++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_k)[c1_i1], 6U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  for (c1_i2 = 0; c1_i2 < 12; c1_i2++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_x)[c1_i2], 5U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  _SFD_DATA_RANGE_CHECK(*chartInstance->c1_t, 4U, 1U, 0U,
                        chartInstance->c1_sfEvent, false);
  for (c1_i3 = 0; c1_i3 < 4; c1_i3++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_s)[c1_i3], 3U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  for (c1_i4 = 0; c1_i4 < 3; c1_i4++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_m1)[c1_i4], 2U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  for (c1_i5 = 0; c1_i5 < 3; c1_i5++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_m0)[c1_i5], 1U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  for (c1_i6 = 0; c1_i6 < 8; c1_i6++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_dots)[c1_i6], 0U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }

  chartInstance->c1_sfEvent = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  c1_hoistedGlobal = *chartInstance->c1_t;
  c1_b_hoistedGlobal = *chartInstance->c1_a;
  for (c1_i7 = 0; c1_i7 < 8; c1_i7++) {
    c1_b_dots[c1_i7] = (*chartInstance->c1_dots)[c1_i7];
  }

  for (c1_i8 = 0; c1_i8 < 3; c1_i8++) {
    c1_b_m0[c1_i8] = (*chartInstance->c1_m0)[c1_i8];
  }

  for (c1_i9 = 0; c1_i9 < 3; c1_i9++) {
    c1_b_m1[c1_i9] = (*chartInstance->c1_m1)[c1_i9];
  }

  for (c1_i10 = 0; c1_i10 < 4; c1_i10++) {
    c1_b_s[c1_i10] = (*chartInstance->c1_s)[c1_i10];
  }

  c1_b_t = c1_hoistedGlobal;
  for (c1_i11 = 0; c1_i11 < 12; c1_i11++) {
    c1_b_x[c1_i11] = (*chartInstance->c1_x)[c1_i11];
  }

  for (c1_i12 = 0; c1_i12 < 12; c1_i12++) {
    c1_b_k[c1_i12] = (*chartInstance->c1_k)[c1_i12];
  }

  c1_b_a = c1_b_hoistedGlobal;
  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 12U, 12U, c1_debug_family_names,
    c1_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_J, 0U, c1_g_sf_marshallOut,
    c1_c_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargin, 1U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargout, 2U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_dots, 3U, c1_f_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_m0, 4U, c1_e_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_m1, 5U, c1_e_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_s, 6U, c1_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_b_t, 7U, c1_b_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_x, 8U, c1_d_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(c1_b_k, 9U, c1_c_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_b_a, 10U, c1_b_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_hat_s, 11U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 4);
  for (c1_i13 = 0; c1_i13 < 12; c1_i13++) {
    c1_c_k[c1_i13] = c1_b_k[c1_i13];
  }

  for (c1_i14 = 0; c1_i14 < 3; c1_i14++) {
    c1_c_m0[c1_i14] = c1_b_m0[c1_i14];
  }

  for (c1_i15 = 0; c1_i15 < 3; c1_i15++) {
    c1_c_m1[c1_i15] = c1_b_m1[c1_i15];
  }

  for (c1_i16 = 0; c1_i16 < 4; c1_i16++) {
    c1_c_s[c1_i16] = c1_b_s[c1_i16];
  }

  for (c1_i17 = 0; c1_i17 < 12; c1_i17++) {
    c1_c_x[c1_i17] = c1_b_x[c1_i17];
  }

  c1_Jac1(chartInstance, c1_b_a, c1_c_k, c1_c_m0, c1_c_m1, c1_c_s, c1_b_t,
          c1_c_x, c1_dv1);
  for (c1_i18 = 0; c1_i18 < 32; c1_i18++) {
    c1_J[c1_i18] = c1_dv1[c1_i18];
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 5);
  sf_mex_printf("%s =\\n", "ans");
  for (c1_i19 = 0; c1_i19 < 32; c1_i19++) {
    c1_varargin_1[c1_i19] = c1_J[c1_i19];
  }

  c1_irank = c1_local_rank(chartInstance, c1_varargin_1);
  c1_r = (real_T)c1_irank;
  c1_u = c1_r;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "disp", 0U, 1U, 14, c1_y);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 6);
  for (c1_i20 = 0; c1_i20 < 32; c1_i20++) {
    c1_b_J[c1_i20] = c1_J[c1_i20];
  }

  c1_pinv(chartInstance, c1_b_J, c1_c_a);
  for (c1_i21 = 0; c1_i21 < 8; c1_i21++) {
    c1_b[c1_i21] = c1_b_dots[c1_i21];
  }

  for (c1_i22 = 0; c1_i22 < 4; c1_i22++) {
    c1_b_hat_s[c1_i22] = 0.0;
  }

  for (c1_i23 = 0; c1_i23 < 4; c1_i23++) {
    c1_b_hat_s[c1_i23] = 0.0;
  }

  for (c1_i24 = 0; c1_i24 < 4; c1_i24++) {
    c1_C[c1_i24] = c1_b_hat_s[c1_i24];
  }

  for (c1_i25 = 0; c1_i25 < 4; c1_i25++) {
    c1_b_hat_s[c1_i25] = c1_C[c1_i25];
  }

  for (c1_i26 = 0; c1_i26 < 4; c1_i26++) {
    c1_b_hat_s[c1_i26] = 0.0;
    c1_i27 = 0;
    for (c1_i29 = 0; c1_i29 < 8; c1_i29++) {
      c1_b_hat_s[c1_i26] += c1_c_a[c1_i27 + c1_i26] * c1_b[c1_i29];
      c1_i27 += 4;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, -6);
  _SFD_SYMBOL_SCOPE_POP();
  for (c1_i28 = 0; c1_i28 < 4; c1_i28++) {
    (*chartInstance->c1_hat_s)[c1_i28] = c1_b_hat_s[c1_i28];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_trackingSimMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  for (c1_i30 = 0; c1_i30 < 4; c1_i30++) {
    _SFD_DATA_RANGE_CHECK((*chartInstance->c1_hat_s)[c1_i30], 8U, 1U, 0U,
                          chartInstance->c1_sfEvent, false);
  }
}

static void mdl_start_c1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static void initSimStructsc1_trackingSim(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static void c1_Jac1(SFc1_trackingSimInstanceStruct *chartInstance, real_T c1_b_a,
                    real_T c1_b_k[12], real_T c1_b_m0[3], real_T c1_b_m1[3],
                    real_T c1_b_s[4], real_T c1_b_t, real_T c1_b_x[12], real_T
                    c1_b_Jac1[32])
{
  uint32_T c1_debug_family_var_map[220];
  real_T c1_k11;
  real_T c1_k12;
  real_T c1_k13;
  real_T c1_k14;
  real_T c1_k21;
  real_T c1_k22;
  real_T c1_k23;
  real_T c1_k24;
  real_T c1_k31;
  real_T c1_k32;
  real_T c1_k33;
  real_T c1_k34;
  real_T c1_m0x;
  real_T c1_m0y;
  real_T c1_m0z;
  real_T c1_m1x;
  real_T c1_m1y;
  real_T c1_m1z;
  real_T c1_s1;
  real_T c1_s2;
  real_T c1_s3;
  real_T c1_s4;
  real_T c1_x1;
  real_T c1_x3;
  real_T c1_x5;
  real_T c1_t2;
  real_T c1_t3;
  real_T c1_t4;
  real_T c1_t5;
  real_T c1_t6;
  real_T c1_t7;
  real_T c1_t8;
  real_T c1_t17;
  real_T c1_t9;
  real_T c1_t10;
  real_T c1_t11;
  real_T c1_t12;
  real_T c1_t13;
  real_T c1_t14;
  real_T c1_t15;
  real_T c1_t16;
  real_T c1_t18;
  real_T c1_t29;
  real_T c1_t19;
  real_T c1_t20;
  real_T c1_t21;
  real_T c1_t22;
  real_T c1_t23;
  real_T c1_t30;
  real_T c1_t24;
  real_T c1_t25;
  real_T c1_t26;
  real_T c1_t27;
  real_T c1_t28;
  real_T c1_t31;
  real_T c1_t32;
  real_T c1_t33;
  real_T c1_t43;
  real_T c1_t34;
  real_T c1_t35;
  real_T c1_t36;
  real_T c1_t37;
  real_T c1_t38;
  real_T c1_t42;
  real_T c1_t39;
  real_T c1_t40;
  real_T c1_t41;
  real_T c1_t44;
  real_T c1_t45;
  real_T c1_t46;
  real_T c1_t47;
  real_T c1_t48;
  real_T c1_t49;
  real_T c1_t117;
  real_T c1_t50;
  real_T c1_t51;
  real_T c1_t52;
  real_T c1_t53;
  real_T c1_t54;
  real_T c1_t55;
  real_T c1_t56;
  real_T c1_t79;
  real_T c1_t57;
  real_T c1_t58;
  real_T c1_t59;
  real_T c1_t81;
  real_T c1_t60;
  real_T c1_t61;
  real_T c1_t62;
  real_T c1_t83;
  real_T c1_t63;
  real_T c1_t64;
  real_T c1_t69;
  real_T c1_t65;
  real_T c1_t66;
  real_T c1_t67;
  real_T c1_t68;
  real_T c1_t70;
  real_T c1_t77;
  real_T c1_t71;
  real_T c1_t72;
  real_T c1_t78;
  real_T c1_t73;
  real_T c1_t74;
  real_T c1_t75;
  real_T c1_t76;
  real_T c1_t80;
  real_T c1_t82;
  real_T c1_t130;
  real_T c1_t84;
  real_T c1_t85;
  real_T c1_t86;
  real_T c1_t87;
  real_T c1_t88;
  real_T c1_t89;
  real_T c1_t90;
  real_T c1_t167;
  real_T c1_t91;
  real_T c1_t92;
  real_T c1_t93;
  real_T c1_t94;
  real_T c1_t95;
  real_T c1_t96;
  real_T c1_t97;
  real_T c1_t153;
  real_T c1_t98;
  real_T c1_t99;
  real_T c1_t100;
  real_T c1_t101;
  real_T c1_t102;
  real_T c1_t103;
  real_T c1_t104;
  real_T c1_t105;
  real_T c1_t107;
  real_T c1_t106;
  real_T c1_t108;
  real_T c1_t109;
  real_T c1_t115;
  real_T c1_t110;
  real_T c1_t111;
  real_T c1_t112;
  real_T c1_t113;
  real_T c1_t121;
  real_T c1_t114;
  real_T c1_t116;
  real_T c1_t118;
  real_T c1_t119;
  real_T c1_t120;
  real_T c1_t122;
  real_T c1_t123;
  real_T c1_t124;
  real_T c1_t125;
  real_T c1_t126;
  real_T c1_t127;
  real_T c1_t144;
  real_T c1_t128;
  real_T c1_t129;
  real_T c1_t131;
  real_T c1_t132;
  real_T c1_t133;
  real_T c1_t134;
  real_T c1_t135;
  real_T c1_t136;
  real_T c1_t137;
  real_T c1_t138;
  real_T c1_t139;
  real_T c1_t140;
  real_T c1_t141;
  real_T c1_t142;
  real_T c1_t143;
  real_T c1_t145;
  real_T c1_t146;
  real_T c1_t147;
  real_T c1_t148;
  real_T c1_t149;
  real_T c1_t150;
  real_T c1_t151;
  real_T c1_t152;
  real_T c1_t154;
  real_T c1_t155;
  real_T c1_t156;
  real_T c1_t157;
  real_T c1_t158;
  real_T c1_t159;
  real_T c1_t160;
  real_T c1_t162;
  real_T c1_t161;
  real_T c1_t163;
  real_T c1_t164;
  real_T c1_t165;
  real_T c1_t166;
  real_T c1_t168;
  real_T c1_t169;
  real_T c1_t170;
  real_T c1_t171;
  real_T c1_t172;
  real_T c1_t173;
  real_T c1_t174;
  real_T c1_t175;
  real_T c1_t176;
  real_T c1_t177;
  real_T c1_t178;
  real_T c1_t179;
  real_T c1_t180;
  real_T c1_t181;
  real_T c1_t182;
  real_T c1_t183;
  real_T c1_t184;
  real_T c1_t185;
  real_T c1_t186;
  real_T c1_nargin = 7.0;
  real_T c1_nargout = 1.0;
  real_T c1_d0;
  real_T c1_c_x[32];
  int32_T c1_c_k;
  int32_T c1_d_k;
  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 220U, 220U, c1_b_debug_family_names,
    c1_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k11, 0U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k12, 1U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k13, 2U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k14, 3U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k21, 4U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k22, 5U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k23, 6U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k24, 7U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k31, 8U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k32, 9U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k33, 10U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_k34, 11U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m0x, 12U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m0y, 13U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m0z, 14U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m1x, 15U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m1y, 16U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_m1z, 17U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_s1, 18U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_s2, 19U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_s3, 20U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_s4, 21U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_x1, 22U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_x3, 23U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_x5, 24U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t2, 25U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t3, 26U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t4, 27U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t5, 28U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t6, 29U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t7, 30U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t8, 31U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t17, 32U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t9, 33U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t10, 34U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t11, 35U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t12, 36U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t13, 37U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t14, 38U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t15, 39U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t16, 40U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t18, 41U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t29, 42U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t19, 43U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t20, 44U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t21, 45U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t22, 46U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t23, 47U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t30, 48U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t24, 49U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t25, 50U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t26, 51U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t27, 52U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t28, 53U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t31, 54U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t32, 55U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t33, 56U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t43, 57U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t34, 58U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t35, 59U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t36, 60U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t37, 61U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t38, 62U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t42, 63U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t39, 64U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t40, 65U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t41, 66U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t44, 67U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t45, 68U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t46, 69U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t47, 70U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t48, 71U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t49, 72U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t117, 73U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t50, 74U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t51, 75U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t52, 76U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t53, 77U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t54, 78U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t55, 79U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t56, 80U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t79, 81U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t57, 82U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t58, 83U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t59, 84U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t81, 85U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t60, 86U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t61, 87U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t62, 88U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t83, 89U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t63, 90U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t64, 91U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t69, 92U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t65, 93U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t66, 94U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t67, 95U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t68, 96U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t70, 97U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t77, 98U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t71, 99U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t72, 100U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t78, 101U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t73, 102U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t74, 103U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t75, 104U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t76, 105U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t80, 106U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t82, 107U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t130, 108U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t84, 109U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t85, 110U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t86, 111U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t87, 112U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t88, 113U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t89, 114U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t90, 115U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t167, 116U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t91, 117U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t92, 118U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t93, 119U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t94, 120U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t95, 121U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t96, 122U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t97, 123U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t153, 124U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t98, 125U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t99, 126U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t100, 127U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t101, 128U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t102, 129U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t103, 130U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t104, 131U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t105, 132U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t107, 133U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t106, 134U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t108, 135U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t109, 136U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t115, 137U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t110, 138U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t111, 139U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t112, 140U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t113, 141U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t121, 142U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t114, 143U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t116, 144U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t118, 145U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t119, 146U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t120, 147U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t122, 148U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t123, 149U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t124, 150U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t125, 151U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t126, 152U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t127, 153U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t144, 154U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t128, 155U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t129, 156U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t131, 157U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t132, 158U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t133, 159U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t134, 160U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t135, 161U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t136, 162U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t137, 163U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t138, 164U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t139, 165U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t140, 166U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t141, 167U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t142, 168U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t143, 169U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t145, 170U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t146, 171U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t147, 172U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t148, 173U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t149, 174U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t150, 175U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t151, 176U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t152, 177U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t154, 178U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t155, 179U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t156, 180U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t157, 181U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t158, 182U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t159, 183U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t160, 184U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t162, 185U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t161, 186U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t163, 187U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t164, 188U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t165, 189U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t166, 190U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t168, 191U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t169, 192U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t170, 193U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t171, 194U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t172, 195U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t173, 196U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t174, 197U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t175, 198U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t176, 199U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t177, 200U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t178, 201U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t179, 202U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t180, 203U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t181, 204U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t182, 205U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t183, 206U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t184, 207U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t185, 208U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_t186, 209U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargin, 210U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargout, 211U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_b_a, 212U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_k, 213U, c1_c_sf_marshallOut,
    c1_f_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_m0, 214U, c1_e_sf_marshallOut,
    c1_e_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_m1, 215U, c1_e_sf_marshallOut,
    c1_e_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_s, 216U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_b_t, 217U, c1_b_sf_marshallOut,
    c1_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_x, 218U, c1_d_sf_marshallOut,
    c1_d_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(c1_b_Jac1, 219U, c1_g_sf_marshallOut,
    c1_c_sf_marshallIn);
  CV_SCRIPT_FCN(0, 0);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 8);
  c1_k11 = c1_b_k[0];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 9);
  c1_k12 = c1_b_k[3];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 10);
  c1_k13 = c1_b_k[6];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 11);
  c1_k14 = c1_b_k[9];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 12);
  c1_k21 = c1_b_k[1];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 13);
  c1_k22 = c1_b_k[4];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 14);
  c1_k23 = c1_b_k[7];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 15);
  c1_k24 = c1_b_k[10];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 16);
  c1_k31 = c1_b_k[2];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 17);
  c1_k32 = c1_b_k[5];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 18);
  c1_k33 = c1_b_k[8];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 19);
  c1_k34 = c1_b_k[11];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 21);
  c1_m0x = c1_b_m0[0];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 22);
  c1_m0y = c1_b_m0[1];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 23);
  c1_m0z = c1_b_m0[2];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 24);
  c1_m1x = c1_b_m1[0];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 25);
  c1_m1y = c1_b_m1[1];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 26);
  c1_m1z = c1_b_m1[2];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 28);
  c1_s1 = c1_b_s[0];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 29);
  c1_s2 = c1_b_s[1];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 30);
  c1_s3 = c1_b_s[2];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 31);
  c1_s4 = c1_b_s[3];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 33);
  c1_x1 = c1_b_x[0];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 34);
  c1_x3 = c1_b_x[2];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 35);
  c1_x5 = c1_b_x[4];
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 37);
  c1_d0 = c1_s1;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t2 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 38);
  c1_d0 = c1_b_t;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t3 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 39);
  c1_d0 = c1_s1;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t4 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 40);
  c1_d0 = c1_x1;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t5 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 41);
  c1_d0 = c1_b_a;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t6 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 42);
  c1_t7 = c1_m0z * c1_t2;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 43);
  c1_t8 = c1_s3 * c1_t2;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 44);
  c1_t17 = c1_m0x * c1_t4;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 45);
  c1_t9 = (c1_t7 + c1_t8) - c1_t17;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 46);
  c1_d0 = c1_b_a;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t10 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 47);
  c1_d0 = c1_b_t;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t11 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 48);
  c1_t12 = c1_m0x * c1_t2;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 49);
  c1_t13 = c1_m0z * c1_t4;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 50);
  c1_t14 = c1_s3 * c1_t4;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 51);
  c1_t15 = (c1_t12 + c1_t13) + c1_t14;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 52);
  c1_d0 = c1_x3;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t16 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 53);
  c1_t18 = c1_t3 * c1_t6 * c1_t9;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 54);
  c1_t29 = c1_t3 * c1_t10 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 55);
  c1_t19 = c1_t18 - c1_t29;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 56);
  c1_d0 = c1_x3;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t20 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 57);
  c1_d0 = c1_x1;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t21 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 58);
  c1_d0 = c1_x5;
  c1_b_sin(chartInstance, &c1_d0);
  c1_t22 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 59);
  c1_t23 = c1_t6 * c1_t9 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 60);
  c1_t30 = c1_t10 * c1_t11 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 61);
  c1_t24 = c1_t23 - c1_t30;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 62);
  c1_d0 = c1_x5;
  c1_b_cos(chartInstance, &c1_d0);
  c1_t25 = c1_d0;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 63);
  c1_t26 = c1_t6 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 65);
  c1_t27 = c1_t9 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 66);
  c1_t28 = c1_t26 + c1_t27;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 67);
  c1_t31 = c1_t3 * c1_t4 * c1_t6;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 68);
  c1_t32 = c1_t2 * c1_t3 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 69);
  c1_t33 = c1_t31 + c1_t32;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 70);
  c1_t43 = c1_t5 * c1_t20;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 71);
  c1_t34 = c1_t21 - c1_t43;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 72);
  c1_t35 = c1_t4 * c1_t6 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 73);
  c1_t36 = c1_t2 * c1_t10 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 74);
  c1_t37 = c1_t35 + c1_t36;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 75);
  c1_t38 = c1_t2 * c1_t6;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 76);
  c1_t42 = c1_t4 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 77);
  c1_t39 = c1_t38 - c1_t42;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 78);
  c1_t40 = c1_t20 * c1_t21;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 79);
  c1_t41 = c1_t5 + c1_t40;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 80);
  c1_t44 = c1_t19 * c1_t34;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 81);
  c1_t45 = c1_t5 * c1_t16 * c1_t22 * c1_t24;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 82);
  c1_t46 = c1_t5 * c1_t16 * c1_t25 * c1_t28;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 83);
  c1_t47 = (c1_t44 + c1_t45) + c1_t46;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 84);
  c1_t48 = c1_t16 * c1_t21 * c1_t22 * c1_t24;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 85);
  c1_t49 = c1_t16 * c1_t21 * c1_t25 * c1_t28;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 86);
  c1_t117 = c1_t19 * c1_t41;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 87);
  c1_t50 = (c1_t48 + c1_t49) - c1_t117;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 88);
  c1_t51 = c1_t16 * c1_t19;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 89);
  c1_t52 = c1_t20 * c1_t22 * c1_t24;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 90);
  c1_t53 = c1_t20 * c1_t25 * c1_t28;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 91);
  c1_t54 = (c1_t51 + c1_t52) + c1_t53;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 92);
  c1_t55 = c1_t16 * c1_t33;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 93);
  c1_t56 = c1_t20 * c1_t22 * c1_t37;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 94);
  c1_t79 = c1_t20 * c1_t25 * c1_t39;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 95);
  c1_t57 = (c1_t55 + c1_t56) - c1_t79;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 96);
  c1_t58 = c1_t33 * c1_t34;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 97);
  c1_t59 = c1_t5 * c1_t16 * c1_t22 * c1_t37;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 98);
  c1_t81 = c1_t5 * c1_t16 * c1_t25 * c1_t39;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 99);
  c1_t60 = (c1_t58 + c1_t59) - c1_t81;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 100);
  c1_t61 = c1_t33 * c1_t41;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 101);
  c1_t62 = c1_t16 * c1_t21 * c1_t25 * c1_t39;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 102);
  c1_t83 = c1_t16 * c1_t21 * c1_t22 * c1_t37;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 103);
  c1_t63 = (c1_t61 + c1_t62) - c1_t83;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 104);
  c1_t64 = c1_m1z * c1_t2;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 105);
  c1_t69 = c1_m1x * c1_t4;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 106);
  c1_t65 = (c1_t8 + c1_t64) - c1_t69;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 107);
  c1_t66 = c1_m1x * c1_t2;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 108);
  c1_t67 = c1_m1z * c1_t4;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 109);
  c1_t68 = (c1_t14 + c1_t66) + c1_t67;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 110);
  c1_t70 = c1_t3 * c1_t6 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 111);
  c1_t77 = c1_t3 * c1_t10 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 112);
  c1_t71 = c1_t70 - c1_t77;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 113);
  c1_t72 = c1_t6 * c1_t11 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 114);
  c1_t78 = c1_t10 * c1_t11 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 115);
  c1_t73 = c1_t72 - c1_t78;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 116);
  c1_t74 = c1_t6 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 117);
  c1_t75 = c1_t10 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 118);
  c1_t76 = c1_t74 + c1_t75;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 119);
  c1_t80 = c1_k13 * c1_t57;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 120);
  c1_t82 = c1_k11 * c1_t60;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 121);
  c1_t130 = c1_k12 * c1_t63;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 122);
  c1_t84 = (c1_t80 + c1_t82) - c1_t130;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 123);
  c1_t85 = c1_t34 * c1_t71;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 124);
  c1_t86 = c1_t5 * c1_t16 * c1_t22 * c1_t73;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 125);
  c1_t87 = c1_t5 * c1_t16 * c1_t25 * c1_t76;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 126);
  c1_t88 = (c1_t85 + c1_t86) + c1_t87;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, MAX_int8_T);
  c1_t89 = c1_t16 * c1_t21 * c1_t22 * c1_t73;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 128U);
  c1_t90 = c1_t16 * c1_t21 * c1_t25 * c1_t76;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 129U);
  c1_t167 = c1_t41 * c1_t71;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 130U);
  c1_t91 = (c1_t89 + c1_t90) - c1_t167;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 131U);
  c1_t92 = c1_t16 * c1_t71;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 132U);
  c1_t93 = c1_t20 * c1_t22 * c1_t73;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 133U);
  c1_t94 = c1_t20 * c1_t25 * c1_t76;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 134U);
  c1_t95 = (c1_t92 + c1_t93) + c1_t94;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 135U);
  c1_t96 = c1_k23 * c1_t57;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 136U);
  c1_t97 = c1_k21 * c1_t60;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 137U);
  c1_t153 = c1_k22 * c1_t63;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 138U);
  c1_t98 = (c1_t96 + c1_t97) - c1_t153;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 139U);
  c1_t99 = c1_t3 * c1_t6 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 140U);
  c1_t100 = c1_t3 * c1_t9 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 141U);
  c1_t101 = c1_t99 + c1_t100;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 142U);
  c1_t102 = c1_t6 * c1_t11 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 143U);
  c1_t103 = c1_t9 * c1_t10 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 144U);
  c1_t104 = c1_t102 + c1_t103;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 145U);
  c1_t105 = c1_t6 * c1_t9;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 146U);
  c1_t107 = c1_t10 * c1_t15;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 147U);
  c1_t106 = c1_t105 - c1_t107;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 148U);
  c1_t108 = c1_t2 * c1_t3 * c1_t6;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 149U);
  c1_t109 = c1_t2 * c1_t6 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 150U);
  c1_t115 = c1_t4 * c1_t10 * c1_t11;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 151U);
  c1_t110 = c1_t109 - c1_t115;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 152U);
  c1_t111 = c1_t4 * c1_t6;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 153U);
  c1_t112 = c1_t2 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 154U);
  c1_t113 = c1_t111 + c1_t112;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 155U);
  c1_t121 = c1_t3 * c1_t4 * c1_t10;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 156U);
  c1_t114 = c1_t108 - c1_t121;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 157U);
  c1_t116 = c1_k11 * c1_t47;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 158U);
  c1_t118 = c1_k12 * c1_t50;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 159U);
  c1_t119 = c1_k13 * c1_t54;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 160U);
  c1_t120 = (c1_t116 + c1_t118) + c1_t119;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 161U);
  c1_t122 = c1_t20 * c1_t22 * c1_t110;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 162U);
  c1_t123 = c1_t20 * c1_t25 * c1_t113;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 163U);
  c1_t124 = c1_t5 * c1_t16 * c1_t22 * c1_t110;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 164U);
  c1_t125 = c1_t5 * c1_t16 * c1_t25 * c1_t113;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 165U);
  c1_t126 = c1_t16 * c1_t21 * c1_t22 * c1_t110;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 166U);
  c1_t127 = c1_t16 * c1_t21 * c1_t25 * c1_t113;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 167U);
  c1_t144 = c1_t41 * c1_t114;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 168U);
  c1_t128 = (c1_t126 + c1_t127) - c1_t144;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 169U);
  c1_t129 = c1_k12 * c1_t128;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 170U);
  c1_t131 = c1_t34 * c1_t101;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 171U);
  c1_t132 = c1_t5 * c1_t16 * c1_t22 * c1_t104;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 172U);
  c1_t133 = (c1_t131 + c1_t132) - c1_t5 * c1_t16 * c1_t25 * c1_t106;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 173U);
  c1_t134 = c1_t41 * c1_t101;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 174U);
  c1_t135 = c1_t16 * c1_t21 * c1_t25 * c1_t106;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 175U);
  c1_t136 = (c1_t134 + c1_t135) - c1_t16 * c1_t21 * c1_t22 * c1_t104;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 176U);
  c1_t137 = c1_t16 * c1_t101;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 177U);
  c1_t138 = c1_t20 * c1_t22 * c1_t104;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 178U);
  c1_t139 = (c1_t137 + c1_t138) - c1_t20 * c1_t25 * c1_t106;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 179U);
  c1_t140 = c1_t16 * (c1_t108 - c1_t121);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 180U);
  c1_t141 = (c1_t122 + c1_t123) + c1_t140;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 181U);
  c1_t142 = c1_t34 * (c1_t108 - c1_t121);
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 182U);
  c1_t143 = (c1_t124 + c1_t125) + c1_t142;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 183U);
  c1_t145 = c1_k21 * c1_t47;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 184U);
  c1_t146 = c1_k22 * c1_t50;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 185U);
  c1_t147 = c1_k23 * c1_t54;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 186U);
  c1_t148 = (c1_t145 + c1_t146) + c1_t147;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 187U);
  c1_t149 = c1_k23 * c1_t141;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 188U);
  c1_t150 = c1_k21 * c1_t143;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 189U);
  c1_t151 = c1_k22 * c1_t128;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 190U);
  c1_t152 = (c1_t149 + c1_t150) + c1_t151;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 191U);
  c1_t154 = c1_t3 * c1_t6 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 192U);
  c1_t155 = c1_t3 * c1_t10 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 193U);
  c1_t156 = c1_t154 + c1_t155;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 194U);
  c1_t157 = c1_t6 * c1_t11 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 195U);
  c1_t158 = c1_t10 * c1_t11 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 196U);
  c1_t159 = c1_t157 + c1_t158;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 197U);
  c1_t160 = c1_t6 * c1_t65;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 198U);
  c1_t162 = c1_t10 * c1_t68;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 199U);
  c1_t161 = c1_t160 - c1_t162;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 200U);
  c1_t163 = c1_k13 * c1_t141;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 201U);
  c1_t164 = c1_k11 * c1_t143;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 202U);
  c1_t165 = (c1_t129 + c1_t163) + c1_t164;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 203U);
  c1_t166 = c1_k11 * c1_t88;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 204U);
  c1_t168 = c1_k12 * c1_t91;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 205U);
  c1_t169 = c1_k13 * c1_t95;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 206U);
  c1_t170 = (c1_t166 + c1_t168) + c1_t169;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 207U);
  c1_t171 = c1_s2 * c1_t165;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 208U);
  c1_t172 = c1_t34 * c1_t156;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 209U);
  c1_t173 = c1_t5 * c1_t16 * c1_t22 * c1_t159;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 210U);
  c1_t174 = (c1_t172 + c1_t173) - c1_t5 * c1_t16 * c1_t25 * c1_t161;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 211U);
  c1_t175 = c1_t41 * c1_t156;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 212U);
  c1_t176 = c1_t16 * c1_t21 * c1_t25 * c1_t161;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 213U);
  c1_t177 = (c1_t175 + c1_t176) - c1_t16 * c1_t21 * c1_t22 * c1_t159;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 214U);
  c1_t178 = c1_t16 * c1_t156;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 215U);
  c1_t179 = c1_t20 * c1_t22 * c1_t159;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 216U);
  c1_t180 = (c1_t178 + c1_t179) - c1_t20 * c1_t25 * c1_t161;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 217U);
  c1_t181 = c1_s4 * c1_t152;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 218U);
  c1_t182 = c1_k21 * c1_t88;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 219U);
  c1_t183 = c1_k22 * c1_t91;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 220U);
  c1_t184 = c1_k23 * c1_t95;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 221U);
  c1_t185 = (c1_t182 + c1_t183) + c1_t184;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 222U);
  c1_t186 = c1_s2 * c1_t152;
  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, 223U);
  c1_c_x[0] = c1_t120;
  c1_c_x[1] = c1_t148;
  c1_c_x[2] = c1_t170;
  c1_c_x[3] = c1_t185;
  c1_c_x[4] = c1_s4 * ((c1_t129 + c1_k13 * ((c1_t122 + c1_t123) + c1_t16 *
    c1_t114)) + c1_k11 * ((c1_t124 + c1_t125) + c1_t34 * c1_t114)) - c1_s2 *
    ((c1_k11 * c1_t133 - c1_k12 * c1_t136) + c1_k13 * c1_t139);
  c1_c_x[5] = c1_t181 - c1_s2 * ((c1_k21 * c1_t133 - c1_k22 * c1_t136) + c1_k23 *
    c1_t139);
  c1_c_x[6] = c1_s4 * c1_t165 - c1_s2 * ((c1_k11 * c1_t174 - c1_k12 * c1_t177) +
    c1_k13 * c1_t180);
  c1_c_x[7] = c1_t181 - c1_s2 * ((c1_k21 * c1_t174 - c1_k22 * c1_t177) + c1_k23 *
    c1_t180);
  c1_c_x[8] = 0.0;
  c1_c_x[9] = 0.0;
  c1_c_x[10] = 0.0;
  c1_c_x[11] = 0.0;
  c1_c_x[12] = c1_t120;
  c1_c_x[13] = c1_t148;
  c1_c_x[14] = c1_t170;
  c1_c_x[15] = c1_t185;
  c1_c_x[16] = c1_t84;
  c1_c_x[17] = c1_t98;
  c1_c_x[18] = c1_t84;
  c1_c_x[19] = c1_t98;
  c1_c_x[20] = c1_t171;
  c1_c_x[21] = c1_t186;
  c1_c_x[22] = c1_t171;
  c1_c_x[23] = c1_t186;
  c1_c_x[24] = 0.0;
  c1_c_x[25] = 0.0;
  c1_c_x[26] = 0.0;
  c1_c_x[27] = 0.0;
  c1_c_x[28] = c1_t84;
  c1_c_x[29] = c1_t98;
  c1_c_x[30] = c1_t84;
  c1_c_x[31] = c1_t98;
  for (c1_c_k = 1; c1_c_k < 33; c1_c_k++) {
    c1_d_k = c1_c_k - 1;
    c1_b_Jac1[c1_d_k] = c1_c_x[c1_d_k];
  }

  _SFD_SCRIPT_CALL(0U, chartInstance->c1_sfEvent, -223);
  _SFD_SYMBOL_SCOPE_POP();
}

static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber)
{
  (void)c1_machineNumber;
  _SFD_SCRIPT_TRANSLATION(c1_chartNumber, c1_instanceNumber, 0U,
    sf_debug_get_script_id("C:\\GroupProject\\Imperial-Team-Awesome\\Jac1.m"));
}

static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i31;
  const mxArray *c1_y = NULL;
  real_T c1_u[4];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  for (c1_i31 = 0; c1_i31 < 4; c1_i31++) {
    c1_u[c1_i31] = (*(real_T (*)[4])c1_inData)[c1_i31];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 4), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_b_hat_s, const char_T *c1_identifier, real_T c1_y[4])
{
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_hat_s), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_hat_s);
}

static void c1_b_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[4])
{
  real_T c1_dv2[4];
  int32_T c1_i32;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv2, 1, 0, 0U, 1, 0U, 1, 4);
  for (c1_i32 = 0; c1_i32 < 4; c1_i32++) {
    c1_y[c1_i32] = c1_dv2[c1_i32];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_hat_s;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[4];
  int32_T c1_i33;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_b_hat_s = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_hat_s), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_hat_s);
  for (c1_i33 = 0; c1_i33 < 4; c1_i33++) {
    (*(real_T (*)[4])c1_outData)[c1_i33] = c1_y[c1_i33];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  real_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(real_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i34;
  int32_T c1_i35;
  const mxArray *c1_y = NULL;
  int32_T c1_i36;
  real_T c1_u[12];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_i34 = 0;
  for (c1_i35 = 0; c1_i35 < 4; c1_i35++) {
    for (c1_i36 = 0; c1_i36 < 3; c1_i36++) {
      c1_u[c1_i36 + c1_i34] = (*(real_T (*)[12])c1_inData)[c1_i36 + c1_i34];
    }

    c1_i34 += 3;
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 2, 3, 4), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static const mxArray *c1_d_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i37;
  const mxArray *c1_y = NULL;
  real_T c1_u[12];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  for (c1_i37 = 0; c1_i37 < 12; c1_i37++) {
    c1_u[c1_i37] = (*(real_T (*)[12])c1_inData)[c1_i37];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 12), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static const mxArray *c1_e_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i38;
  const mxArray *c1_y = NULL;
  real_T c1_u[3];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  for (c1_i38 = 0; c1_i38 < 3; c1_i38++) {
    c1_u[c1_i38] = (*(real_T (*)[3])c1_inData)[c1_i38];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 3), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static const mxArray *c1_f_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i39;
  const mxArray *c1_y = NULL;
  real_T c1_u[8];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  for (c1_i39 = 0; c1_i39 < 8; c1_i39++) {
    c1_u[c1_i39] = (*(real_T (*)[8])c1_inData)[c1_i39];
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 8), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static real_T c1_c_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  real_T c1_y;
  real_T c1_d1;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_d1, 1, 0, 0U, 0, 0U, 0);
  c1_y = c1_d1;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_nargout;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_nargout = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_nargout), &c1_thisId);
  sf_mex_destroy(&c1_nargout);
  *(real_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_g_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_i40;
  int32_T c1_i41;
  const mxArray *c1_y = NULL;
  int32_T c1_i42;
  real_T c1_u[32];
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_i40 = 0;
  for (c1_i41 = 0; c1_i41 < 4; c1_i41++) {
    for (c1_i42 = 0; c1_i42 < 8; c1_i42++) {
      c1_u[c1_i42 + c1_i40] = (*(real_T (*)[32])c1_inData)[c1_i42 + c1_i40];
    }

    c1_i40 += 8;
  }

  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 2, 8, 4), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static void c1_d_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[32])
{
  real_T c1_dv3[32];
  int32_T c1_i43;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv3, 1, 0, 0U, 1, 0U, 2, 8, 4);
  for (c1_i43 = 0; c1_i43 < 32; c1_i43++) {
    c1_y[c1_i43] = c1_dv3[c1_i43];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_J;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[32];
  int32_T c1_i44;
  int32_T c1_i45;
  int32_T c1_i46;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_J = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_J), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_J);
  c1_i44 = 0;
  for (c1_i45 = 0; c1_i45 < 4; c1_i45++) {
    for (c1_i46 = 0; c1_i46 < 8; c1_i46++) {
      (*(real_T (*)[32])c1_outData)[c1_i46 + c1_i44] = c1_y[c1_i46 + c1_i44];
    }

    c1_i44 += 8;
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static void c1_e_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[12])
{
  real_T c1_dv4[12];
  int32_T c1_i47;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv4, 1, 0, 0U, 1, 0U, 1, 12);
  for (c1_i47 = 0; c1_i47 < 12; c1_i47++) {
    c1_y[c1_i47] = c1_dv4[c1_i47];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_d_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_x;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[12];
  int32_T c1_i48;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_b_x = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_e_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_x), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_x);
  for (c1_i48 = 0; c1_i48 < 12; c1_i48++) {
    (*(real_T (*)[12])c1_outData)[c1_i48] = c1_y[c1_i48];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static void c1_f_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[3])
{
  real_T c1_dv5[3];
  int32_T c1_i49;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv5, 1, 0, 0U, 1, 0U, 1, 3);
  for (c1_i49 = 0; c1_i49 < 3; c1_i49++) {
    c1_y[c1_i49] = c1_dv5[c1_i49];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_e_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_m1;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[3];
  int32_T c1_i50;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_b_m1 = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_f_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_m1), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_m1);
  for (c1_i50 = 0; c1_i50 < 3; c1_i50++) {
    (*(real_T (*)[3])c1_outData)[c1_i50] = c1_y[c1_i50];
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

static void c1_g_emlrt_marshallIn(SFc1_trackingSimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId, real_T c1_y[12])
{
  real_T c1_dv6[12];
  int32_T c1_i51;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), c1_dv6, 1, 0, 0U, 1, 0U, 2, 3, 4);
  for (c1_i51 = 0; c1_i51 < 12; c1_i51++) {
    c1_y[c1_i51] = c1_dv6[c1_i51];
  }

  sf_mex_destroy(&c1_u);
}

static void c1_f_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_k;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y[12];
  int32_T c1_i52;
  int32_T c1_i53;
  int32_T c1_i54;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_b_k = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_g_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_k), &c1_thisId, c1_y);
  sf_mex_destroy(&c1_b_k);
  c1_i52 = 0;
  for (c1_i53 = 0; c1_i53 < 4; c1_i53++) {
    for (c1_i54 = 0; c1_i54 < 3; c1_i54++) {
      (*(real_T (*)[12])c1_outData)[c1_i54 + c1_i52] = c1_y[c1_i54 + c1_i52];
    }

    c1_i52 += 3;
  }

  sf_mex_destroy(&c1_mxArrayInData);
}

const mxArray *sf_c1_trackingSim_get_eml_resolved_functions_info(void)
{
  const mxArray *c1_nameCaptureInfo = NULL;
  const char * c1_data[3] = {
    "789c6360f4f46500023e20b66066606003d21c40ccc40001ac503e23128688b330f042f94d409c9c9f57925a510291cc4bcc4d65808194fcdcccbcc4bc9290ca"
    "825486a2d4e2fc9cb2d414b04c5a664e6a48666eaa4f3e12c72313c8c9754392827340524519c57093197290391000f2870103c21f2c68fe8001983f0488d4c7",
    "081543e86361f04a4c3604871b017d6c68f6b18143a534292715626f0201fdfa68fa41fc68d758672b7df7a2fcd28280a2fcacd4e4127dcfdc82d4a2ccc41cdd"
    "90d4c45c5dc7726050e7a6ea831ca997cb80ee4e362cf620c72f2722bc262c15bae648817e78f80eb47e0d24fd8c58f43320d1a4aa0700220d3d1d",
    "" };

  c1_nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(c1_data, 840U, &c1_nameCaptureInfo);
  return c1_nameCaptureInfo;
}

static real_T c1_cos(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x)
{
  real_T c1_c_x;
  c1_c_x = c1_b_x;
  c1_b_cos(chartInstance, &c1_c_x);
  return c1_c_x;
}

static real_T c1_sin(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x)
{
  real_T c1_c_x;
  c1_c_x = c1_b_x;
  c1_b_sin(chartInstance, &c1_c_x);
  return c1_c_x;
}

static int32_T c1_local_rank(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_A[32])
{
  int32_T c1_irank;
  int32_T c1_b_k;
  int32_T c1_i55;
  int32_T c1_c_k;
  real_T c1_b_A[32];
  real_T c1_b_s[4];
  real_T c1_b_x;
  real_T c1_absxk;
  real_T c1_r;
  int32_T c1_exponent;
  real_T c1_tol;
  int32_T c1_b_exponent;
  int32_T c1_d_k;
  int32_T c1_c_exponent;
  int32_T c1_e_k;
  boolean_T exitg1;
  c1_irank = 0;
  for (c1_b_k = 0; c1_b_k < 32; c1_b_k++) {
    c1_c_k = c1_b_k;
    if (!c1_isfinite(chartInstance, c1_A[c1_c_k])) {
      c1_error(chartInstance);
    }
  }

  for (c1_i55 = 0; c1_i55 < 32; c1_i55++) {
    c1_b_A[c1_i55] = c1_A[c1_i55];
  }

  c1_xzsvdc(chartInstance, c1_b_A, c1_b_s);
  c1_b_x = c1_b_s[0];
  c1_absxk = c1_abs(chartInstance, c1_b_x);
  if (c1_isfinite(chartInstance, c1_absxk)) {
    if (c1_absxk <= 2.2250738585072014E-308) {
      c1_r = 4.94065645841247E-324;
    } else {
      frexp(c1_absxk, &c1_exponent);
      c1_b_exponent = c1_exponent;
      c1_c_exponent = c1_b_exponent;
      c1_c_exponent;
      c1_r = ldexp(1.0, c1_c_exponent - 53);
    }
  } else {
    c1_r = rtNaN;
  }

  c1_tol = 8.0 * c1_r;
  c1_d_k = 1;
  exitg1 = false;
  while ((exitg1 == false) && (c1_d_k < 5)) {
    c1_e_k = c1_d_k - 1;
    if (c1_b_s[c1_e_k] > c1_tol) {
      c1_irank++;
      c1_d_k++;
    } else {
      exitg1 = true;
    }
  }

  return c1_irank;
}

static boolean_T c1_isfinite(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_b_x)
{
  real_T c1_c_x;
  boolean_T c1_b_b;
  boolean_T c1_b0;
  real_T c1_d_x;
  boolean_T c1_c_b;
  boolean_T c1_b1;
  (void)chartInstance;
  c1_c_x = c1_b_x;
  c1_b_b = muDoubleScalarIsInf(c1_c_x);
  c1_b0 = !c1_b_b;
  c1_d_x = c1_b_x;
  c1_c_b = muDoubleScalarIsNaN(c1_d_x);
  c1_b1 = !c1_c_b;
  return c1_b0 && c1_b1;
}

static void c1_error(SFc1_trackingSimInstanceStruct *chartInstance)
{
  const mxArray *c1_y = NULL;
  static char_T c1_u[33] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T', 'L',
    'A', 'B', ':', 's', 'v', 'd', '_', 'm', 'a', 't', 'r', 'i', 'x', 'W', 'i',
    't', 'h', 'N', 'a', 'N', 'I', 'n', 'f' };

  (void)chartInstance;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 10, 0U, 1U, 0U, 2, 1, 33), false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message", 1U,
    1U, 14, c1_y));
}

static void c1_xzsvdc(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_A[32], real_T c1_S[4])
{
  int32_T c1_i56;
  int32_T c1_i57;
  real_T c1_b_s[4];
  int32_T c1_i58;
  real_T c1_e[4];
  int32_T c1_q;
  real_T c1_work[8];
  int32_T c1_m;
  int32_T c1_b_q;
  int32_T c1_qp1;
  int32_T c1_qm1;
  int32_T c1_c_q;
  int32_T c1_qq;
  int32_T c1_nmq;
  int32_T c1_nmqp1;
  real_T c1_iter;
  boolean_T c1_apply_transform;
  real_T c1_snorm;
  int32_T c1_ii;
  real_T c1_rt;
  int32_T c1_i59;
  real_T c1_b_A;
  int32_T c1_b_qp1;
  real_T c1_B;
  boolean_T c1_overflow;
  int32_T c1_b_ii;
  real_T c1_b_x;
  real_T c1_nrm;
  real_T c1_c_A[32];
  real_T c1_varargin_1;
  real_T c1_d_A;
  real_T c1_y;
  real_T c1_varargin_2;
  real_T c1_b_B;
  real_T c1_c_x;
  int32_T c1_jj;
  int32_T c1_b_k;
  real_T c1_b_varargin_2;
  real_T c1_d_x;
  real_T c1_b_y;
  real_T c1_absx;
  int32_T c1_i60;
  real_T c1_varargin_3;
  real_T c1_c_y;
  real_T c1_r;
  real_T c1_d;
  boolean_T c1_b_overflow;
  real_T c1_e_x;
  real_T c1_f_x;
  int32_T c1_b_jj;
  int32_T c1_c_k;
  real_T c1_d_y;
  real_T c1_e_y;
  int32_T c1_pmq;
  int32_T c1_qjj;
  real_T c1_f_y;
  real_T c1_g_x;
  real_T c1_e_A;
  int32_T c1_i61;
  int32_T c1_c_ii;
  real_T c1_g_y;
  real_T c1_c_B;
  int32_T c1_i62;
  real_T c1_h_x;
  real_T c1_i_x;
  int32_T c1_n;
  real_T c1_h_y;
  real_T c1_i_y;
  real_T c1_b_e[4];
  real_T c1_b_a;
  real_T c1_maxval;
  real_T c1_j_x;
  int32_T c1_i63;
  real_T c1_f_A[32];
  int32_T c1_ix0;
  real_T c1_b_varargin_1;
  real_T c1_j_y;
  real_T c1_b_absx;
  int32_T c1_qs;
  real_T c1_kase;
  real_T c1_c_varargin_2;
  real_T c1_k_y;
  real_T c1_b_d;
  int32_T c1_b_ix0;
  real_T c1_d_B;
  int32_T c1_b_m;
  real_T c1_test0;
  real_T c1_d_varargin_2;
  real_T c1_b_t;
  real_T c1_g_A[32];
  int32_T c1_c_a;
  real_T c1_l_y;
  int32_T c1_d_q;
  real_T c1_ztest0;
  real_T c1_b_varargin_3;
  real_T c1_m_y;
  real_T c1_h_A;
  int32_T c1_c;
  real_T c1_n_y;
  int32_T c1_d_a;
  real_T c1_k_x;
  real_T c1_e_B;
  int32_T c1_b;
  real_T c1_o_y;
  int32_T c1_b_b;
  real_T c1_f;
  int32_T c1_mm1;
  real_T c1_p_y;
  real_T c1_l_x;
  int32_T c1_b_c;
  int32_T c1_b_n;
  int32_T c1_e_a;
  real_T c1_d2;
  real_T c1_m_x;
  int32_T c1_c_n;
  real_T c1_q_y;
  int32_T c1_f_a;
  real_T c1_g_a;
  int32_T c1_c_b;
  int32_T c1_i64;
  real_T c1_d3;
  real_T c1_r_y;
  real_T c1_h_a;
  real_T c1_n_x;
  int32_T c1_d_b;
  int32_T c1_c_ix0;
  boolean_T c1_c_overflow;
  int32_T c1_e_q;
  int32_T c1_f_q;
  real_T c1_d4;
  real_T c1_o_x;
  int32_T c1_d_ix0;
  real_T c1_s_y;
  int32_T c1_i65;
  int32_T c1_d_n;
  int32_T c1_i_a;
  int32_T c1_c_m;
  real_T c1_d5;
  real_T c1_t_y;
  real_T c1_u_y;
  int32_T c1_j_a;
  real_T c1_k_a;
  int32_T c1_e_b;
  int32_T c1_l_a;
  real_T c1_d6;
  int32_T c1_e_ix0;
  real_T c1_f_B;
  int32_T c1_f_b;
  int32_T c1_f_ix0;
  int32_T c1_d_ii;
  int32_T c1_m_a;
  int32_T c1_g_b;
  real_T c1_c_varargin_1[5];
  int32_T c1_n_a;
  real_T c1_v_y;
  int32_T c1_o_a;
  int32_T c1_g_ix0;
  int32_T c1_h_b;
  int32_T c1_p_a;
  int32_T c1_c_c;
  real_T c1_w_y;
  int32_T c1_i_b;
  int32_T c1_q_a;
  boolean_T c1_d_overflow;
  int32_T c1_j_b;
  int32_T c1_k_b;
  real_T c1_x_y;
  boolean_T c1_e_overflow;
  int32_T c1_d_c;
  boolean_T c1_f_overflow;
  int32_T c1_e_c;
  int32_T c1_e_n;
  int32_T c1_l_b;
  int32_T c1_r_a;
  real_T c1_s_a;
  int32_T c1_f_c;
  int32_T c1_d_k;
  real_T c1_scale;
  int32_T c1_m_b;
  int32_T c1_h_ix0;
  int32_T c1_e_k;
  int32_T c1_t_a;
  real_T c1_test;
  int32_T c1_f_k;
  real_T c1_i_A;
  int32_T c1_i66;
  int32_T c1_f_n;
  int32_T c1_n_b;
  real_T c1_g_B;
  int32_T c1_u_a;
  real_T c1_v_a;
  int32_T c1_i67;
  real_T c1_p_x;
  int32_T c1_o_b;
  int32_T c1_i_ix0;
  int32_T c1_g_k;
  int32_T c1_w_a;
  real_T c1_t1;
  real_T c1_y_y;
  int32_T c1_x_a;
  int32_T c1_j_ix0;
  real_T c1_j_A;
  int32_T c1_p_b;
  real_T c1_b_t1;
  real_T c1_q_x;
  int32_T c1_q_b;
  int32_T c1_y_a;
  real_T c1_h_B;
  int32_T c1_ab_a;
  real_T c1_ztest;
  real_T c1_b_f;
  real_T c1_c_t1;
  real_T c1_ab_y;
  boolean_T c1_g_overflow;
  int32_T c1_g_c;
  real_T c1_r_x;
  int32_T c1_r_b;
  real_T c1_cs;
  real_T c1_sn;
  real_T c1_unusedU0;
  real_T c1_sm;
  int32_T c1_s_b;
  real_T c1_bb_y;
  boolean_T c1_h_overflow;
  real_T c1_b_cs;
  real_T c1_b_sn;
  real_T c1_k_A;
  int32_T c1_h_c;
  real_T c1_s_x;
  real_T c1_i_B;
  int32_T c1_h_k;
  int32_T c1_bb_a;
  real_T c1_cb_y;
  real_T c1_c_cs;
  real_T c1_t_x;
  int32_T c1_t_b;
  real_T c1_db_y;
  int32_T c1_i_k;
  real_T c1_c_sn;
  real_T c1_eb_y;
  int32_T c1_i68;
  real_T c1_u_x;
  int32_T c1_j_k;
  int32_T c1_cb_a;
  real_T c1_fb_y;
  real_T c1_l_A;
  int32_T c1_u_b;
  int32_T c1_k_k;
  int32_T c1_km1;
  real_T c1_smm1;
  real_T c1_j_B;
  int32_T c1_db_a;
  real_T c1_m_A;
  real_T c1_v_x;
  int32_T c1_v_b;
  real_T c1_k_B;
  int32_T c1_c_qp1;
  real_T c1_gb_y;
  boolean_T c1_i_overflow;
  real_T c1_w_x;
  boolean_T c1_j_overflow;
  real_T c1_x_x;
  real_T c1_hb_y;
  real_T c1_ib_y;
  real_T c1_y_x;
  real_T c1_jb_y;
  int32_T c1_l_k;
  real_T c1_kb_y;
  int32_T c1_e_ii;
  real_T c1_emm1;
  real_T c1_n_A;
  int32_T c1_m_k;
  real_T c1_l_B;
  int32_T c1_d_qp1;
  real_T c1_ab_x;
  boolean_T c1_k_overflow;
  real_T c1_lb_y;
  real_T c1_bb_x;
  real_T c1_mb_y;
  int32_T c1_c_jj;
  real_T c1_sqds;
  real_T c1_o_A;
  real_T c1_m_B;
  int32_T c1_e_qp1;
  real_T c1_cb_x;
  boolean_T c1_l_overflow;
  int32_T c1_qp1jj;
  real_T c1_nb_y;
  int32_T c1_i69;
  real_T c1_db_x;
  real_T c1_ob_y;
  int32_T c1_d_jj;
  real_T c1_eqds;
  real_T c1_p_A[32];
  real_T c1_q_A;
  real_T c1_eb_x;
  real_T c1_fb_x;
  real_T c1_r_A;
  real_T c1_w_b;
  real_T c1_n_B;
  real_T c1_i_c;
  real_T c1_gb_x;
  real_T c1_pb_y;
  real_T c1_hb_x;
  real_T c1_qb_y;
  real_T c1_shift;
  int32_T c1_i70;
  real_T c1_g;
  int32_T c1_g_q;
  real_T c1_s_A;
  int32_T c1_b_mm1;
  real_T c1_o_B;
  real_T c1_b_work[8];
  int32_T c1_eb_a;
  real_T c1_ib_x;
  int32_T c1_x_b;
  real_T c1_rb_y;
  int32_T c1_fb_a;
  real_T c1_jb_x;
  int32_T c1_y_b;
  real_T c1_sb_y;
  boolean_T c1_m_overflow;
  int32_T c1_n_k;
  int32_T c1_kp1;
  real_T c1_c_f;
  real_T c1_unusedU1;
  real_T c1_d_cs;
  real_T c1_d_sn;
  real_T c1_d_f;
  real_T c1_unusedU2;
  real_T c1_e_cs;
  real_T c1_e_sn;
  boolean_T guard1 = false;
  boolean_T guard2 = false;
  boolean_T guard3 = false;
  boolean_T guard4 = false;
  boolean_T exitg1;
  boolean_T exitg2;
  boolean_T exitg3;
  boolean_T exitg4;
  boolean_T guard11 = false;
  for (c1_i56 = 0; c1_i56 < 4; c1_i56++) {
    c1_b_s[c1_i56] = 0.0;
  }

  for (c1_i57 = 0; c1_i57 < 4; c1_i57++) {
    c1_e[c1_i57] = 0.0;
  }

  for (c1_i58 = 0; c1_i58 < 8; c1_i58++) {
    c1_work[c1_i58] = 0.0;
  }

  for (c1_q = 1; c1_q < 5; c1_q++) {
    c1_b_q = c1_q - 1;
    c1_qp1 = c1_b_q + 2;
    c1_qm1 = c1_b_q;
    c1_qq = (c1_b_q + (c1_qm1 << 3)) + 1;
    c1_nmq = 7 - c1_b_q;
    c1_nmqp1 = c1_nmq + 1;
    c1_apply_transform = false;
    if (c1_b_q + 1 <= 4) {
      for (c1_i59 = 0; c1_i59 < 32; c1_i59++) {
        c1_c_A[c1_i59] = c1_A[c1_i59];
      }

      c1_nrm = c1_xnrm2(chartInstance, c1_nmqp1, c1_c_A, c1_qq);
      if (c1_nrm > 0.0) {
        c1_apply_transform = true;
        c1_absx = c1_nrm;
        c1_d = c1_A[c1_qq - 1];
        if (c1_d < 0.0) {
          c1_f_y = -c1_absx;
        } else {
          c1_f_y = c1_absx;
        }

        c1_b_s[c1_b_q] = c1_f_y;
        c1_n = c1_nmqp1;
        c1_b_a = c1_b_s[c1_b_q];
        c1_ix0 = c1_qq;
        if (c1_abs(chartInstance, c1_b_a) >= 1.0020841800044864E-292) {
          c1_d_B = c1_b_a;
          c1_l_y = c1_d_B;
          c1_n_y = c1_l_y;
          c1_o_y = 1.0 / c1_n_y;
          c1_b_n = c1_n;
          c1_g_a = c1_o_y;
          c1_c_ix0 = c1_ix0;
          c1_d_n = c1_b_n;
          c1_k_a = c1_g_a;
          c1_f_ix0 = c1_c_ix0;
          c1_g_ix0 = c1_f_ix0;
          c1_q_a = c1_d_n;
          c1_d_c = c1_q_a;
          c1_l_b = c1_d_c - 1;
          c1_f_c = c1_l_b;
          c1_t_a = c1_f_ix0;
          c1_n_b = c1_f_c;
          c1_i67 = c1_t_a + c1_n_b;
          c1_w_a = c1_g_ix0;
          c1_p_b = c1_i67;
          c1_ab_a = c1_w_a;
          c1_r_b = c1_p_b;
          c1_h_overflow = ((!(c1_ab_a > c1_r_b)) && (c1_r_b > 2147483646));
          if (c1_h_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_h_overflow);
          }

          for (c1_i_k = c1_g_ix0; c1_i_k <= c1_i67; c1_i_k++) {
            c1_k_k = c1_i_k - 1;
            c1_A[c1_k_k] *= c1_k_a;
          }
        } else {
          c1_b_ix0 = c1_ix0;
          c1_c_a = c1_n;
          c1_c = c1_c_a;
          c1_b = c1_c - 1;
          c1_b_c = c1_b;
          c1_f_a = c1_ix0;
          c1_d_b = c1_b_c;
          c1_i65 = c1_f_a + c1_d_b;
          c1_j_a = c1_b_ix0;
          c1_f_b = c1_i65;
          c1_o_a = c1_j_a;
          c1_i_b = c1_f_b;
          c1_e_overflow = ((!(c1_o_a > c1_i_b)) && (c1_i_b > 2147483646));
          if (c1_e_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_e_overflow);
          }

          for (c1_e_k = c1_b_ix0; c1_e_k <= c1_i65; c1_e_k++) {
            c1_g_k = c1_e_k - 1;
            c1_j_A = c1_A[c1_g_k];
            c1_h_B = c1_b_a;
            c1_r_x = c1_j_A;
            c1_bb_y = c1_h_B;
            c1_s_x = c1_r_x;
            c1_cb_y = c1_bb_y;
            c1_db_y = c1_s_x / c1_cb_y;
            c1_A[c1_g_k] = c1_db_y;
          }
        }

        c1_A[c1_qq - 1]++;
        c1_b_s[c1_b_q] = -c1_b_s[c1_b_q];
      } else {
        c1_b_s[c1_b_q] = 0.0;
      }
    }

    c1_b_qp1 = c1_qp1;
    c1_overflow = false;
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_jj = c1_b_qp1; c1_jj < 5; c1_jj++) {
      c1_b_jj = c1_jj - 1;
      c1_qjj = (c1_b_q + (c1_b_jj << 3)) + 1;
      if (c1_apply_transform) {
        for (c1_i62 = 0; c1_i62 < 32; c1_i62++) {
          c1_f_A[c1_i62] = c1_A[c1_i62];
        }

        for (c1_i63 = 0; c1_i63 < 32; c1_i63++) {
          c1_g_A[c1_i63] = c1_A[c1_i63];
        }

        c1_b_t = c1_xdotc(chartInstance, c1_nmqp1, c1_f_A, c1_qq, c1_g_A, c1_qjj);
        c1_h_A = c1_b_t;
        c1_e_B = c1_A[c1_b_q + (c1_b_q << 3)];
        c1_l_x = c1_h_A;
        c1_q_y = c1_e_B;
        c1_n_x = c1_l_x;
        c1_s_y = c1_q_y;
        c1_u_y = c1_n_x / c1_s_y;
        c1_b_t = -c1_u_y;
        c1_e_xaxpy(chartInstance, c1_nmqp1, c1_b_t, c1_qq, c1_A, c1_qjj);
      }

      c1_e[c1_b_jj] = c1_A[c1_qjj - 1];
    }

    if (c1_b_q + 1 <= 2) {
      c1_pmq = 3 - c1_b_q;
      for (c1_i61 = 0; c1_i61 < 4; c1_i61++) {
        c1_b_e[c1_i61] = c1_e[c1_i61];
      }

      c1_nrm = c1_b_xnrm2(chartInstance, c1_pmq, c1_b_e, c1_qp1);
      if (c1_nrm == 0.0) {
        c1_e[c1_b_q] = 0.0;
      } else {
        c1_b_absx = c1_nrm;
        c1_b_d = c1_e[c1_qp1 - 1];
        if (c1_b_d < 0.0) {
          c1_m_y = -c1_b_absx;
        } else {
          c1_m_y = c1_b_absx;
        }

        c1_e[c1_b_q] = c1_m_y;
        c1_c_n = c1_pmq;
        c1_h_a = c1_e[c1_b_q];
        c1_d_ix0 = c1_qp1;
        if (c1_abs(chartInstance, c1_h_a) >= 1.0020841800044864E-292) {
          c1_f_B = c1_h_a;
          c1_v_y = c1_f_B;
          c1_w_y = c1_v_y;
          c1_x_y = 1.0 / c1_w_y;
          c1_e_n = c1_c_n;
          c1_s_a = c1_x_y;
          c1_h_ix0 = c1_d_ix0;
          c1_f_n = c1_e_n;
          c1_v_a = c1_s_a;
          c1_i_ix0 = c1_h_ix0;
          c1_j_ix0 = c1_i_ix0;
          c1_y_a = c1_f_n;
          c1_g_c = c1_y_a;
          c1_s_b = c1_g_c - 1;
          c1_h_c = c1_s_b;
          c1_bb_a = c1_i_ix0;
          c1_t_b = c1_h_c;
          c1_i68 = c1_bb_a + c1_t_b;
          c1_cb_a = c1_j_ix0;
          c1_u_b = c1_i68;
          c1_db_a = c1_cb_a;
          c1_v_b = c1_u_b;
          c1_i_overflow = ((!(c1_db_a > c1_v_b)) && (c1_v_b > 2147483646));
          if (c1_i_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_i_overflow);
          }

          for (c1_l_k = c1_j_ix0; c1_l_k <= c1_i68; c1_l_k++) {
            c1_m_k = c1_l_k - 1;
            c1_e[c1_m_k] *= c1_v_a;
          }
        } else {
          c1_e_ix0 = c1_d_ix0;
          c1_n_a = c1_c_n;
          c1_c_c = c1_n_a;
          c1_k_b = c1_c_c - 1;
          c1_e_c = c1_k_b;
          c1_r_a = c1_d_ix0;
          c1_m_b = c1_e_c;
          c1_i66 = c1_r_a + c1_m_b;
          c1_u_a = c1_e_ix0;
          c1_o_b = c1_i66;
          c1_x_a = c1_u_a;
          c1_q_b = c1_o_b;
          c1_g_overflow = ((!(c1_x_a > c1_q_b)) && (c1_q_b > 2147483646));
          if (c1_g_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_g_overflow);
          }

          for (c1_h_k = c1_e_ix0; c1_h_k <= c1_i66; c1_h_k++) {
            c1_j_k = c1_h_k - 1;
            c1_l_A = c1_e[c1_j_k];
            c1_j_B = c1_h_a;
            c1_v_x = c1_l_A;
            c1_gb_y = c1_j_B;
            c1_x_x = c1_v_x;
            c1_ib_y = c1_gb_y;
            c1_jb_y = c1_x_x / c1_ib_y;
            c1_e[c1_j_k] = c1_jb_y;
          }
        }

        c1_e[c1_qp1 - 1]++;
        c1_e[c1_b_q] = -c1_e[c1_b_q];
        if (c1_qp1 <= 8) {
          c1_c_qp1 = c1_qp1;
          c1_j_overflow = false;
          if (c1_j_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_j_overflow);
          }

          for (c1_e_ii = c1_c_qp1; c1_e_ii < 9; c1_e_ii++) {
            c1_b_ii = c1_e_ii - 1;
            c1_work[c1_b_ii] = 0.0;
          }

          c1_d_qp1 = c1_qp1;
          c1_k_overflow = false;
          if (c1_k_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_k_overflow);
          }

          for (c1_c_jj = c1_d_qp1; c1_c_jj < 5; c1_c_jj++) {
            c1_b_jj = c1_c_jj - 1;
            c1_qp1jj = c1_qp1 + (c1_b_jj << 3);
            for (c1_i69 = 0; c1_i69 < 32; c1_i69++) {
              c1_p_A[c1_i69] = c1_A[c1_i69];
            }

            c1_f_xaxpy(chartInstance, c1_nmq, c1_e[c1_b_jj], c1_p_A, c1_qp1jj,
                       c1_work, c1_qp1);
          }

          c1_e_qp1 = c1_qp1;
          c1_l_overflow = false;
          if (c1_l_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_l_overflow);
          }

          for (c1_d_jj = c1_e_qp1; c1_d_jj < 5; c1_d_jj++) {
            c1_b_jj = c1_d_jj - 1;
            c1_r_A = -c1_e[c1_b_jj];
            c1_n_B = c1_e[c1_qp1 - 1];
            c1_gb_x = c1_r_A;
            c1_pb_y = c1_n_B;
            c1_hb_x = c1_gb_x;
            c1_qb_y = c1_pb_y;
            c1_b_t = c1_hb_x / c1_qb_y;
            c1_qp1jj = c1_qp1 + (c1_b_jj << 3);
            for (c1_i70 = 0; c1_i70 < 8; c1_i70++) {
              c1_b_work[c1_i70] = c1_work[c1_i70];
            }

            c1_g_xaxpy(chartInstance, c1_nmq, c1_b_t, c1_b_work, c1_qp1, c1_A,
                       c1_qp1jj);
          }
        }
      }
    }
  }

  c1_m = 3;
  c1_e[2] = c1_A[26];
  c1_e[3] = 0.0;
  for (c1_c_q = 1; c1_c_q < 5; c1_c_q++) {
    c1_b_q = c1_c_q - 1;
    if (c1_b_s[c1_b_q] != 0.0) {
      c1_rt = c1_abs(chartInstance, c1_b_s[c1_b_q]);
      c1_b_A = c1_b_s[c1_b_q];
      c1_B = c1_rt;
      c1_b_x = c1_b_A;
      c1_y = c1_B;
      c1_c_x = c1_b_x;
      c1_b_y = c1_y;
      c1_r = c1_c_x / c1_b_y;
      c1_b_s[c1_b_q] = c1_rt;
      if (c1_b_q + 1 < 4) {
        c1_e_A = c1_e[c1_b_q];
        c1_c_B = c1_r;
        c1_i_x = c1_e_A;
        c1_i_y = c1_c_B;
        c1_j_x = c1_i_x;
        c1_j_y = c1_i_y;
        c1_k_y = c1_j_x / c1_j_y;
        c1_e[c1_b_q] = c1_k_y;
      }
    }

    if (c1_b_q + 1 < 4) {
      if (c1_e[c1_b_q] != 0.0) {
        c1_rt = c1_abs(chartInstance, c1_e[c1_b_q]);
        c1_d_A = c1_rt;
        c1_b_B = c1_e[c1_b_q];
        c1_d_x = c1_d_A;
        c1_c_y = c1_b_B;
        c1_f_x = c1_d_x;
        c1_e_y = c1_c_y;
        c1_r = c1_f_x / c1_e_y;
        c1_e[c1_b_q] = c1_rt;
        c1_b_s[c1_b_q + 1] *= c1_r;
      }
    }
  }

  c1_iter = 0.0;
  c1_snorm = 0.0;
  for (c1_ii = 1; c1_ii < 5; c1_ii++) {
    c1_b_ii = c1_ii - 1;
    c1_varargin_1 = c1_abs(chartInstance, c1_b_s[c1_b_ii]);
    c1_varargin_2 = c1_abs(chartInstance, c1_e[c1_b_ii]);
    c1_b_varargin_2 = c1_varargin_1;
    c1_varargin_3 = c1_varargin_2;
    c1_e_x = c1_b_varargin_2;
    c1_d_y = c1_varargin_3;
    c1_g_x = c1_e_x;
    c1_g_y = c1_d_y;
    c1_h_x = c1_g_x;
    c1_h_y = c1_g_y;
    c1_maxval = muDoubleScalarMax(c1_h_x, c1_h_y);
    c1_b_varargin_1 = c1_snorm;
    c1_c_varargin_2 = c1_maxval;
    c1_d_varargin_2 = c1_b_varargin_1;
    c1_b_varargin_3 = c1_c_varargin_2;
    c1_k_x = c1_d_varargin_2;
    c1_p_y = c1_b_varargin_3;
    c1_m_x = c1_k_x;
    c1_r_y = c1_p_y;
    c1_o_x = c1_m_x;
    c1_t_y = c1_r_y;
    c1_snorm = muDoubleScalarMax(c1_o_x, c1_t_y);
  }

  exitg1 = false;
  while ((exitg1 == false) && (c1_m + 1 > 0)) {
    if (c1_iter >= 75.0) {
      c1_b_error(chartInstance);
      exitg1 = true;
    } else {
      c1_b_q = c1_m;
      c1_i60 = c1_m;
      c1_b_overflow = false;
      if (c1_b_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_b_overflow);
      }

      c1_c_ii = c1_i60;
      guard3 = false;
      guard4 = false;
      exitg4 = false;
      while ((exitg4 == false) && (c1_c_ii > -1)) {
        c1_b_ii = c1_c_ii;
        c1_b_q = c1_b_ii;
        if (c1_b_ii == 0) {
          exitg4 = true;
        } else {
          c1_test0 = c1_abs(chartInstance, c1_b_s[c1_b_ii - 1]) + c1_abs
            (chartInstance, c1_b_s[c1_b_ii]);
          c1_ztest0 = c1_abs(chartInstance, c1_e[c1_b_ii - 1]);
          if (c1_ztest0 <= 2.2204460492503131E-16 * c1_test0) {
            guard4 = true;
            exitg4 = true;
          } else if (c1_ztest0 <= 1.0020841800044864E-292) {
            guard4 = true;
            exitg4 = true;
          } else {
            guard11 = false;
            if (c1_iter > 20.0) {
              if (c1_ztest0 <= 2.2204460492503131E-16 * c1_snorm) {
                guard3 = true;
                exitg4 = true;
              } else {
                guard11 = true;
              }
            } else {
              guard11 = true;
            }

            if (guard11 == true) {
              c1_c_ii--;
              guard3 = false;
              guard4 = false;
            }
          }
        }
      }

      if (guard4 == true) {
        guard3 = true;
      }

      if (guard3 == true) {
        c1_e[c1_b_ii - 1] = 0.0;
      }

      if (c1_b_q == c1_m) {
        c1_kase = 4.0;
      } else {
        c1_qs = c1_m + 1;
        c1_b_m = c1_m + 1;
        c1_d_q = c1_b_q;
        c1_d_a = c1_b_m;
        c1_b_b = c1_d_q;
        c1_e_a = c1_d_a;
        c1_c_b = c1_b_b;
        c1_c_overflow = ((!(c1_e_a < c1_c_b)) && (c1_c_b < -2147483647));
        if (c1_c_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_c_overflow);
        }

        c1_d_ii = c1_b_m;
        guard2 = false;
        exitg3 = false;
        while ((exitg3 == false) && (c1_d_ii >= c1_d_q)) {
          c1_b_ii = c1_d_ii;
          c1_qs = c1_b_ii;
          if (c1_b_ii == c1_b_q) {
            exitg3 = true;
          } else {
            c1_test = 0.0;
            if (c1_b_ii < c1_m + 1) {
              c1_test = c1_abs(chartInstance, c1_e[c1_b_ii - 1]);
            }

            if (c1_b_ii > c1_b_q + 1) {
              c1_test += c1_abs(chartInstance, c1_e[c1_b_ii - 2]);
            }

            c1_ztest = c1_abs(chartInstance, c1_b_s[c1_b_ii - 1]);
            if (c1_ztest <= 2.2204460492503131E-16 * c1_test) {
              guard2 = true;
              exitg3 = true;
            } else if (c1_ztest <= 1.0020841800044864E-292) {
              guard2 = true;
              exitg3 = true;
            } else {
              c1_d_ii--;
              guard2 = false;
            }
          }
        }

        if (guard2 == true) {
          c1_b_s[c1_b_ii - 1] = 0.0;
        }

        if (c1_qs == c1_b_q) {
          c1_kase = 3.0;
        } else if (c1_qs == c1_m + 1) {
          c1_kase = 1.0;
        } else {
          c1_kase = 2.0;
          c1_b_q = c1_qs;
        }
      }

      c1_b_q;
      switch ((int32_T)c1_kase) {
       case 1:
        c1_f = c1_e[c1_m - 1];
        c1_e[c1_m - 1] = 0.0;
        c1_i64 = c1_m;
        c1_e_q = c1_b_q + 1;
        c1_i_a = c1_i64;
        c1_e_b = c1_e_q;
        c1_m_a = c1_i_a;
        c1_h_b = c1_e_b;
        c1_d_overflow = ((!(c1_m_a < c1_h_b)) && (c1_h_b < -2147483647));
        if (c1_d_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_d_overflow);
        }

        for (c1_d_k = c1_i64; c1_d_k >= c1_e_q; c1_d_k--) {
          c1_c_k = c1_d_k - 1;
          c1_t1 = c1_b_s[c1_c_k];
          c1_b_t1 = c1_t1;
          c1_b_f = c1_f;
          c1_b_xrotg(chartInstance, &c1_b_t1, &c1_b_f, &c1_cs, &c1_sn);
          c1_t1 = c1_b_t1;
          c1_f = c1_b_f;
          c1_c_cs = c1_cs;
          c1_c_sn = c1_sn;
          c1_b_s[c1_c_k] = c1_t1;
          if (c1_c_k + 1 > c1_b_q + 1) {
            c1_km1 = c1_c_k - 1;
            c1_f = -c1_c_sn * c1_e[c1_km1];
            c1_e[c1_km1] *= c1_c_cs;
          }
        }
        break;

       case 2:
        c1_qm1 = c1_b_q - 1;
        c1_f = c1_e[c1_qm1];
        c1_e[c1_qm1] = 0.0;
        c1_f_q = c1_b_q + 1;
        c1_c_m = c1_m + 1;
        c1_l_a = c1_f_q;
        c1_g_b = c1_c_m;
        c1_p_a = c1_l_a;
        c1_j_b = c1_g_b;
        c1_f_overflow = ((!(c1_p_a > c1_j_b)) && (c1_j_b > 2147483646));
        if (c1_f_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_f_overflow);
        }

        for (c1_f_k = c1_f_q; c1_f_k <= c1_c_m; c1_f_k++) {
          c1_c_k = c1_f_k - 1;
          c1_t1 = c1_b_s[c1_c_k];
          c1_c_t1 = c1_t1;
          c1_unusedU0 = c1_f;
          c1_b_xrotg(chartInstance, &c1_c_t1, &c1_unusedU0, &c1_b_cs, &c1_b_sn);
          c1_t1 = c1_c_t1;
          c1_c_cs = c1_b_cs;
          c1_c_sn = c1_b_sn;
          c1_b_s[c1_c_k] = c1_t1;
          c1_f = -c1_c_sn * c1_e[c1_c_k];
          c1_e[c1_c_k] *= c1_c_cs;
        }
        break;

       case 3:
        c1_mm1 = c1_m - 1;
        c1_d2 = c1_abs(chartInstance, c1_b_s[c1_m]);
        c1_d3 = c1_abs(chartInstance, c1_b_s[c1_mm1]);
        c1_d4 = c1_abs(chartInstance, c1_e[c1_mm1]);
        c1_d5 = c1_abs(chartInstance, c1_b_s[c1_b_q]);
        c1_d6 = c1_abs(chartInstance, c1_e[c1_b_q]);
        c1_c_varargin_1[0] = c1_d2;
        c1_c_varargin_1[1] = c1_d3;
        c1_c_varargin_1[2] = c1_d4;
        c1_c_varargin_1[3] = c1_d5;
        c1_c_varargin_1[4] = c1_d6;
        c1_scale = c1_eml_extremum(chartInstance, c1_c_varargin_1);
        c1_i_A = c1_b_s[c1_m];
        c1_g_B = c1_scale;
        c1_p_x = c1_i_A;
        c1_y_y = c1_g_B;
        c1_q_x = c1_p_x;
        c1_ab_y = c1_y_y;
        c1_sm = c1_q_x / c1_ab_y;
        c1_k_A = c1_b_s[c1_mm1];
        c1_i_B = c1_scale;
        c1_t_x = c1_k_A;
        c1_eb_y = c1_i_B;
        c1_u_x = c1_t_x;
        c1_fb_y = c1_eb_y;
        c1_smm1 = c1_u_x / c1_fb_y;
        c1_m_A = c1_e[c1_mm1];
        c1_k_B = c1_scale;
        c1_w_x = c1_m_A;
        c1_hb_y = c1_k_B;
        c1_y_x = c1_w_x;
        c1_kb_y = c1_hb_y;
        c1_emm1 = c1_y_x / c1_kb_y;
        c1_n_A = c1_b_s[c1_b_q];
        c1_l_B = c1_scale;
        c1_ab_x = c1_n_A;
        c1_lb_y = c1_l_B;
        c1_bb_x = c1_ab_x;
        c1_mb_y = c1_lb_y;
        c1_sqds = c1_bb_x / c1_mb_y;
        c1_o_A = c1_e[c1_b_q];
        c1_m_B = c1_scale;
        c1_cb_x = c1_o_A;
        c1_nb_y = c1_m_B;
        c1_db_x = c1_cb_x;
        c1_ob_y = c1_nb_y;
        c1_eqds = c1_db_x / c1_ob_y;
        c1_q_A = (c1_smm1 + c1_sm) * (c1_smm1 - c1_sm) + c1_emm1 * c1_emm1;
        c1_eb_x = c1_q_A;
        c1_fb_x = c1_eb_x;
        c1_w_b = c1_fb_x / 2.0;
        c1_i_c = c1_sm * c1_emm1;
        c1_i_c *= c1_i_c;
        guard1 = false;
        if (c1_w_b != 0.0) {
          guard1 = true;
        } else if (c1_i_c != 0.0) {
          guard1 = true;
        } else {
          c1_shift = 0.0;
        }

        if (guard1 == true) {
          c1_shift = c1_w_b * c1_w_b + c1_i_c;
          c1_b_sqrt(chartInstance, &c1_shift);
          if (c1_w_b < 0.0) {
            c1_shift = -c1_shift;
          }

          c1_s_A = c1_i_c;
          c1_o_B = c1_w_b + c1_shift;
          c1_ib_x = c1_s_A;
          c1_rb_y = c1_o_B;
          c1_jb_x = c1_ib_x;
          c1_sb_y = c1_rb_y;
          c1_shift = c1_jb_x / c1_sb_y;
        }

        c1_f = (c1_sqds + c1_sm) * (c1_sqds - c1_sm) + c1_shift;
        c1_g = c1_sqds * c1_eqds;
        c1_g_q = c1_b_q + 1;
        c1_b_mm1 = c1_mm1 + 1;
        c1_eb_a = c1_g_q;
        c1_x_b = c1_b_mm1;
        c1_fb_a = c1_eb_a;
        c1_y_b = c1_x_b;
        c1_m_overflow = ((!(c1_fb_a > c1_y_b)) && (c1_y_b > 2147483646));
        if (c1_m_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_m_overflow);
        }

        for (c1_n_k = c1_g_q; c1_n_k <= c1_b_mm1; c1_n_k++) {
          c1_c_k = c1_n_k - 1;
          c1_km1 = c1_c_k - 1;
          c1_kp1 = c1_c_k + 1;
          c1_c_f = c1_f;
          c1_unusedU1 = c1_g;
          c1_b_xrotg(chartInstance, &c1_c_f, &c1_unusedU1, &c1_d_cs, &c1_d_sn);
          c1_f = c1_c_f;
          c1_c_cs = c1_d_cs;
          c1_c_sn = c1_d_sn;
          if (c1_c_k + 1 > c1_b_q + 1) {
            c1_e[c1_km1] = c1_f;
          }

          c1_f = c1_c_cs * c1_b_s[c1_c_k] + c1_c_sn * c1_e[c1_c_k];
          c1_e[c1_c_k] = c1_c_cs * c1_e[c1_c_k] - c1_c_sn * c1_b_s[c1_c_k];
          c1_g = c1_c_sn * c1_b_s[c1_kp1];
          c1_b_s[c1_kp1] *= c1_c_cs;
          c1_d_f = c1_f;
          c1_unusedU2 = c1_g;
          c1_b_xrotg(chartInstance, &c1_d_f, &c1_unusedU2, &c1_e_cs, &c1_e_sn);
          c1_f = c1_d_f;
          c1_c_cs = c1_e_cs;
          c1_c_sn = c1_e_sn;
          c1_b_s[c1_c_k] = c1_f;
          c1_f = c1_c_cs * c1_e[c1_c_k] + c1_c_sn * c1_b_s[c1_kp1];
          c1_b_s[c1_kp1] = -c1_c_sn * c1_e[c1_c_k] + c1_c_cs * c1_b_s[c1_kp1];
          c1_g = c1_c_sn * c1_e[c1_kp1];
          c1_e[c1_kp1] *= c1_c_cs;
        }

        c1_e[c1_m - 1] = c1_f;
        c1_iter++;
        break;

       default:
        if (c1_b_s[c1_b_q] < 0.0) {
          c1_b_s[c1_b_q] = -c1_b_s[c1_b_q];
        }

        c1_qp1 = c1_b_q + 1;
        exitg2 = false;
        while ((exitg2 == false) && (c1_b_q + 1 < 4)) {
          if (c1_b_s[c1_b_q] < c1_b_s[c1_qp1]) {
            c1_rt = c1_b_s[c1_b_q];
            c1_b_s[c1_b_q] = c1_b_s[c1_qp1];
            c1_b_s[c1_qp1] = c1_rt;
            c1_b_q = c1_qp1;
            c1_qp1 = c1_b_q + 1;
          } else {
            exitg2 = true;
          }
        }

        c1_iter = 0.0;
        c1_m--;
        break;
      }
    }
  }

  for (c1_b_k = 1; c1_b_k < 5; c1_b_k++) {
    c1_c_k = c1_b_k - 1;
    c1_S[c1_c_k] = c1_b_s[c1_c_k];
  }
}

static void c1_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static real_T c1_xnrm2(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[32], int32_T c1_ix0)
{
  real_T c1_y;
  int32_T c1_b_n;
  int32_T c1_b_ix0;
  real_T c1_scale;
  int32_T c1_kstart;
  int32_T c1_b_a;
  int32_T c1_c;
  int32_T c1_c_a;
  int32_T c1_b_c;
  int32_T c1_d_a;
  int32_T c1_b;
  int32_T c1_kend;
  int32_T c1_b_kstart;
  int32_T c1_b_kend;
  int32_T c1_e_a;
  int32_T c1_b_b;
  int32_T c1_f_a;
  int32_T c1_c_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_c_k;
  real_T c1_absxk;
  real_T c1_b_t;
  c1_b_n = c1_n;
  c1_b_ix0 = c1_ix0;
  c1_y = 0.0;
  if (c1_b_n < 1) {
  } else if (c1_b_n == 1) {
    c1_y = c1_abs(chartInstance, c1_b_x[c1_b_ix0 - 1]);
  } else {
    c1_scale = 2.2250738585072014E-308;
    c1_kstart = c1_b_ix0;
    c1_b_a = c1_b_n;
    c1_c = c1_b_a;
    c1_c_a = c1_c - 1;
    c1_b_c = c1_c_a;
    c1_d_a = c1_kstart;
    c1_b = c1_b_c;
    c1_kend = c1_d_a + c1_b;
    c1_b_kstart = c1_kstart;
    c1_b_kend = c1_kend;
    c1_e_a = c1_b_kstart;
    c1_b_b = c1_b_kend;
    c1_f_a = c1_e_a;
    c1_c_b = c1_b_b;
    c1_overflow = ((!(c1_f_a > c1_c_b)) && (c1_c_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = c1_b_kstart; c1_b_k <= c1_b_kend; c1_b_k++) {
      c1_c_k = c1_b_k - 1;
      c1_absxk = c1_abs(chartInstance, c1_b_x[c1_c_k]);
      if (c1_absxk > c1_scale) {
        c1_b_t = c1_scale / c1_absxk;
        c1_y = 1.0 + c1_y * c1_b_t * c1_b_t;
        c1_scale = c1_absxk;
      } else {
        c1_b_t = c1_absxk / c1_scale;
        c1_y += c1_b_t * c1_b_t;
      }
    }

    c1_y = c1_scale * muDoubleScalarSqrt(c1_y);
  }

  return c1_y;
}

static real_T c1_abs(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x)
{
  real_T c1_c_x;
  real_T c1_d_x;
  (void)chartInstance;
  c1_c_x = c1_b_x;
  c1_d_x = c1_c_x;
  return muDoubleScalarAbs(c1_d_x);
}

static void c1_realmin(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_eml_realmin(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_check_forloop_overflow_error(SFc1_trackingSimInstanceStruct
  *chartInstance, boolean_T c1_overflow)
{
  const mxArray *c1_y = NULL;
  static char_T c1_u[34] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'i', 'n', 't', '_', 'f', 'o', 'r', 'l', 'o', 'o', 'p',
    '_', 'o', 'v', 'e', 'r', 'f', 'l', 'o', 'w' };

  const mxArray *c1_b_y = NULL;
  static char_T c1_b_u[5] = { 'i', 'n', 't', '3', '2' };

  (void)chartInstance;
  if (!c1_overflow) {
  } else {
    c1_y = NULL;
    sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 10, 0U, 1U, 0U, 2, 1, 34),
                  false);
    c1_b_y = NULL;
    sf_mex_assign(&c1_b_y, sf_mex_create("y", c1_b_u, 10, 0U, 1U, 0U, 2, 1, 5),
                  false);
    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                      sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message",
      1U, 2U, 14, c1_y, 14, c1_b_y));
  }
}

static void c1_eps(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static real_T c1_xdotc(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[32], int32_T c1_iy0)
{
  int32_T c1_i71;
  int32_T c1_i72;
  real_T c1_c_x[32];
  real_T c1_b_y[32];
  for (c1_i71 = 0; c1_i71 < 32; c1_i71++) {
    c1_c_x[c1_i71] = c1_b_x[c1_i71];
  }

  for (c1_i72 = 0; c1_i72 < 32; c1_i72++) {
    c1_b_y[c1_i72] = c1_y[c1_i72];
  }

  return c1_xdot(chartInstance, c1_n, c1_c_x, c1_ix0, c1_b_y, c1_iy0);
}

static real_T c1_xdot(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
                      c1_n, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[32],
                      int32_T c1_iy0)
{
  real_T c1_d;
  int32_T c1_b_n;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_c_n;
  int32_T c1_c_ix0;
  int32_T c1_c_iy0;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_d_n;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_b_a;
  int32_T c1_c_a;
  c1_b_n = c1_n;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_c_n = c1_b_n;
  c1_c_ix0 = c1_b_ix0;
  c1_c_iy0 = c1_b_iy0;
  c1_d = 0.0;
  if (c1_c_n < 1) {
  } else {
    c1_ix = c1_c_ix0 - 1;
    c1_iy = c1_c_iy0 - 1;
    c1_d_n = c1_c_n;
    c1_b = c1_d_n;
    c1_b_b = c1_b;
    c1_overflow = ((!(1 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 1; c1_b_k <= c1_d_n; c1_b_k++) {
      c1_d += c1_b_x[c1_ix] * c1_y[c1_iy];
      c1_b_a = c1_ix + 1;
      c1_ix = c1_b_a;
      c1_c_a = c1_iy + 1;
      c1_iy = c1_c_a;
    }
  }

  return c1_d;
}

static void c1_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T c1_n,
                     real_T c1_b_a, int32_T c1_ix0, real_T c1_y[32], int32_T
                     c1_iy0, real_T c1_b_y[32])
{
  int32_T c1_i73;
  for (c1_i73 = 0; c1_i73 < 32; c1_i73++) {
    c1_b_y[c1_i73] = c1_y[c1_i73];
  }

  c1_e_xaxpy(chartInstance, c1_n, c1_b_a, c1_ix0, c1_b_y, c1_iy0);
}

static real_T c1_b_xnrm2(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[4], int32_T c1_ix0)
{
  real_T c1_y;
  int32_T c1_b_n;
  int32_T c1_b_ix0;
  real_T c1_scale;
  int32_T c1_kstart;
  int32_T c1_b_a;
  int32_T c1_c;
  int32_T c1_c_a;
  int32_T c1_b_c;
  int32_T c1_d_a;
  int32_T c1_b;
  int32_T c1_kend;
  int32_T c1_b_kstart;
  int32_T c1_b_kend;
  int32_T c1_e_a;
  int32_T c1_b_b;
  int32_T c1_f_a;
  int32_T c1_c_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_c_k;
  real_T c1_absxk;
  real_T c1_b_t;
  c1_b_n = c1_n;
  c1_b_ix0 = c1_ix0;
  c1_y = 0.0;
  if (c1_b_n < 1) {
  } else if (c1_b_n == 1) {
    c1_y = c1_abs(chartInstance, c1_b_x[c1_b_ix0 - 1]);
  } else {
    c1_scale = 2.2250738585072014E-308;
    c1_kstart = c1_b_ix0;
    c1_b_a = c1_b_n;
    c1_c = c1_b_a;
    c1_c_a = c1_c - 1;
    c1_b_c = c1_c_a;
    c1_d_a = c1_kstart;
    c1_b = c1_b_c;
    c1_kend = c1_d_a + c1_b;
    c1_b_kstart = c1_kstart;
    c1_b_kend = c1_kend;
    c1_e_a = c1_b_kstart;
    c1_b_b = c1_b_kend;
    c1_f_a = c1_e_a;
    c1_c_b = c1_b_b;
    c1_overflow = ((!(c1_f_a > c1_c_b)) && (c1_c_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = c1_b_kstart; c1_b_k <= c1_b_kend; c1_b_k++) {
      c1_c_k = c1_b_k - 1;
      c1_absxk = c1_abs(chartInstance, c1_b_x[c1_c_k]);
      if (c1_absxk > c1_scale) {
        c1_b_t = c1_scale / c1_absxk;
        c1_y = 1.0 + c1_y * c1_b_t * c1_b_t;
        c1_scale = c1_absxk;
      } else {
        c1_b_t = c1_absxk / c1_scale;
        c1_y += c1_b_t * c1_b_t;
      }
    }

    c1_y = c1_scale * muDoubleScalarSqrt(c1_y);
  }

  return c1_y;
}

static void c1_b_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_b_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[8],
  int32_T c1_iy0, real_T c1_b_y[8])
{
  int32_T c1_i74;
  int32_T c1_i75;
  real_T c1_c_x[32];
  for (c1_i74 = 0; c1_i74 < 8; c1_i74++) {
    c1_b_y[c1_i74] = c1_y[c1_i74];
  }

  for (c1_i75 = 0; c1_i75 < 32; c1_i75++) {
    c1_c_x[c1_i75] = c1_b_x[c1_i75];
  }

  c1_f_xaxpy(chartInstance, c1_n, c1_b_a, c1_c_x, c1_ix0, c1_b_y, c1_iy0);
}

static void c1_c_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[8], int32_T c1_ix0, real_T c1_y[32],
  int32_T c1_iy0, real_T c1_b_y[32])
{
  int32_T c1_i76;
  int32_T c1_i77;
  real_T c1_c_x[8];
  for (c1_i76 = 0; c1_i76 < 32; c1_i76++) {
    c1_b_y[c1_i76] = c1_y[c1_i76];
  }

  for (c1_i77 = 0; c1_i77 < 8; c1_i77++) {
    c1_c_x[c1_i77] = c1_b_x[c1_i77];
  }

  c1_g_xaxpy(chartInstance, c1_n, c1_b_a, c1_c_x, c1_ix0, c1_b_y, c1_iy0);
}

static void c1_c_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_dimagree(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_b_error(SFc1_trackingSimInstanceStruct *chartInstance)
{
  const mxArray *c1_y = NULL;
  static char_T c1_u[30] = { 'C', 'o', 'd', 'e', 'r', ':', 'M', 'A', 'T', 'L',
    'A', 'B', ':', 's', 'v', 'd', '_', 'N', 'o', 'C', 'o', 'n', 'v', 'e', 'r',
    'g', 'e', 'n', 'c', 'e' };

  (void)chartInstance;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 10, 0U, 1U, 0U, 2, 1, 30), false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message", 1U,
    1U, 14, c1_y));
}

static void c1_xrotg(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_a, real_T c1_b, real_T *c1_c_a, real_T *c1_b_b, real_T
                     *c1_c, real_T *c1_b_s)
{
  *c1_c_a = c1_b_a;
  *c1_b_b = c1_b;
  c1_b_xrotg(chartInstance, c1_c_a, c1_b_b, c1_c, c1_b_s);
}

static real_T c1_sqrt(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x)
{
  real_T c1_c_x;
  c1_c_x = c1_b_x;
  c1_b_sqrt(chartInstance, &c1_c_x);
  return c1_c_x;
}

static void c1_c_error(SFc1_trackingSimInstanceStruct *chartInstance)
{
  const mxArray *c1_y = NULL;
  static char_T c1_u[30] = { 'C', 'o', 'd', 'e', 'r', ':', 't', 'o', 'o', 'l',
    'b', 'o', 'x', ':', 'E', 'l', 'F', 'u', 'n', 'D', 'o', 'm', 'a', 'i', 'n',
    'E', 'r', 'r', 'o', 'r' };

  const mxArray *c1_b_y = NULL;
  static char_T c1_b_u[4] = { 's', 'q', 'r', 't' };

  (void)chartInstance;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", c1_u, 10, 0U, 1U, 0U, 2, 1, 30), false);
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", c1_b_u, 10, 0U, 1U, 0U, 2, 1, 4),
                false);
  sf_mex_call_debug(sfGlobalDebugInstanceStruct, "error", 0U, 1U, 14,
                    sf_mex_call_debug(sfGlobalDebugInstanceStruct, "message", 1U,
    2U, 14, c1_y, 14, c1_b_y));
}

static void c1_d_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static real_T c1_eml_extremum(SFc1_trackingSimInstanceStruct *chartInstance,
  real_T c1_b_x[5])
{
  int32_T c1_ixstart;
  real_T c1_mtmp;
  real_T c1_c_x;
  boolean_T c1_foundnan;
  int32_T c1_ix;
  int32_T c1_i78;
  real_T c1_b_mtmp;
  boolean_T c1_overflow;
  int32_T c1_b_ix;
  real_T c1_d_x;
  int32_T c1_c_ix;
  boolean_T c1_b;
  real_T c1_b_a;
  real_T c1_b_b;
  boolean_T c1_p;
  boolean_T exitg1;
  c1_ixstart = 1;
  c1_mtmp = c1_b_x[0];
  c1_c_x = c1_mtmp;
  c1_foundnan = muDoubleScalarIsNaN(c1_c_x);
  if (c1_foundnan) {
    c1_ix = 2;
    exitg1 = false;
    while ((exitg1 == false) && (c1_ix < 6)) {
      c1_b_ix = c1_ix - 1;
      c1_ixstart = c1_b_ix + 1;
      c1_d_x = c1_b_x[c1_b_ix];
      c1_b = muDoubleScalarIsNaN(c1_d_x);
      if (!c1_b) {
        c1_mtmp = c1_b_x[c1_b_ix];
        exitg1 = true;
      } else {
        c1_ix++;
      }
    }
  }

  if (c1_ixstart < 5) {
    c1_i78 = c1_ixstart;
    c1_overflow = false;
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_c_ix = c1_i78 + 1; c1_c_ix < 6; c1_c_ix++) {
      c1_b_ix = c1_c_ix - 1;
      c1_b_a = c1_b_x[c1_b_ix];
      c1_b_b = c1_mtmp;
      c1_p = (c1_b_a > c1_b_b);
      if (c1_p) {
        c1_mtmp = c1_b_x[c1_b_ix];
      }
    }
  }

  c1_b_mtmp = c1_mtmp;
  return c1_b_mtmp;
}

static void c1_pinv(SFc1_trackingSimInstanceStruct *chartInstance, real_T c1_A
                    [32], real_T c1_X[32])
{
  int32_T c1_i79;
  int32_T c1_b_k;
  int32_T c1_i80;
  int32_T c1_c_k;
  real_T c1_b_A[32];
  real_T c1_U[32];
  real_T c1_b_s[4];
  real_T c1_V[16];
  int32_T c1_i81;
  int32_T c1_d_k;
  real_T c1_S[16];
  real_T c1_tol;
  int32_T c1_e_k;
  int32_T c1_r;
  int32_T c1_f_k;
  int32_T c1_g_k;
  int32_T c1_vcol;
  int32_T c1_b_a;
  int32_T c1_b_r;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_j;
  int32_T c1_b_j;
  real_T c1_y;
  real_T c1_z;
  int32_T c1_c_a;
  boolean_T exitg1;
  for (c1_i79 = 0; c1_i79 < 32; c1_i79++) {
    c1_X[c1_i79] = 0.0;
  }

  for (c1_b_k = 0; c1_b_k < 32; c1_b_k++) {
    c1_c_k = c1_b_k;
    if (!c1_isfinite(chartInstance, c1_A[c1_c_k])) {
      c1_error(chartInstance);
    }
  }

  for (c1_i80 = 0; c1_i80 < 32; c1_i80++) {
    c1_b_A[c1_i80] = c1_A[c1_i80];
  }

  c1_b_xzsvdc(chartInstance, c1_b_A, c1_U, c1_b_s, c1_V);
  for (c1_i81 = 0; c1_i81 < 16; c1_i81++) {
    c1_S[c1_i81] = 0.0;
  }

  for (c1_d_k = 0; c1_d_k < 4; c1_d_k++) {
    c1_e_k = c1_d_k;
    c1_S[c1_e_k + (c1_e_k << 2)] = c1_b_s[c1_e_k];
  }

  c1_tol = 8.0 * c1_S[0] * 2.2204460492503131E-16;
  c1_r = 0;
  c1_f_k = 1;
  exitg1 = false;
  while ((exitg1 == false) && (c1_f_k < 5)) {
    c1_g_k = c1_f_k - 1;
    if (!(c1_S[c1_g_k + (c1_g_k << 2)] > c1_tol)) {
      exitg1 = true;
    } else {
      c1_b_a = c1_r + 1;
      c1_r = c1_b_a;
      c1_f_k++;
    }
  }

  if (c1_r > 0) {
    c1_vcol = 1;
    c1_b_r = c1_r;
    c1_b = c1_b_r;
    c1_b_b = c1_b;
    c1_overflow = ((!(1 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_j = 1; c1_j <= c1_b_r; c1_j++) {
      c1_b_j = c1_j - 1;
      c1_y = c1_S[c1_b_j + (c1_b_j << 2)];
      c1_z = 1.0 / c1_y;
      c1_d_xscal(chartInstance, c1_z, c1_V, c1_vcol);
      c1_c_a = c1_vcol + 4;
      c1_vcol = c1_c_a;
    }

    c1_b_xgemm(chartInstance, c1_r, c1_V, c1_U, c1_X);
  }
}

static void c1_b_xzsvdc(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_A[32], real_T c1_U[32], real_T c1_S[4], real_T c1_V[16])
{
  int32_T c1_i82;
  int32_T c1_i83;
  real_T c1_b_s[4];
  int32_T c1_i84;
  real_T c1_e[4];
  int32_T c1_i85;
  real_T c1_work[8];
  int32_T c1_i86;
  int32_T c1_q;
  real_T c1_Vf[16];
  int32_T c1_m;
  int32_T c1_b_q;
  int32_T c1_qp1;
  int32_T c1_qm1;
  int32_T c1_c_q;
  int32_T c1_qq;
  int32_T c1_nmq;
  int32_T c1_nmqp1;
  int32_T c1_d_q;
  boolean_T c1_apply_transform;
  int32_T c1_i87;
  int32_T c1_e_q;
  int32_T c1_b_qp1;
  boolean_T c1_overflow;
  real_T c1_nrm;
  real_T c1_b_A[32];
  real_T c1_iter;
  int32_T c1_ii;
  int32_T c1_c_qp1;
  real_T c1_snorm;
  int32_T c1_b_ii;
  int32_T c1_pmq;
  boolean_T c1_b_overflow;
  int32_T c1_jj;
  int32_T c1_c_ii;
  real_T c1_rt;
  int32_T c1_qp1q;
  real_T c1_absx;
  real_T c1_c_A;
  int32_T c1_d_qp1;
  int32_T c1_d_ii;
  real_T c1_d;
  real_T c1_B;
  boolean_T c1_c_overflow;
  int32_T c1_b_jj;
  int32_T c1_c_jj;
  real_T c1_b_x;
  int32_T c1_f_q;
  int32_T c1_qjj;
  real_T c1_y;
  real_T c1_varargin_1;
  real_T c1_d_A;
  real_T c1_b_y;
  boolean_T c1_d_overflow;
  real_T c1_varargin_2;
  real_T c1_b_B;
  real_T c1_c_x;
  int32_T c1_d_jj;
  int32_T c1_g_q;
  int32_T c1_i88;
  int32_T c1_b_k;
  real_T c1_b_varargin_2;
  real_T c1_d_x;
  real_T c1_c_y;
  boolean_T c1_e_overflow;
  int32_T c1_i89;
  int32_T c1_n;
  int32_T c1_i90;
  real_T c1_varargin_3;
  real_T c1_d_y;
  real_T c1_r;
  int32_T c1_i91;
  int32_T c1_e_ii;
  real_T c1_b_a;
  boolean_T c1_f_overflow;
  real_T c1_e_x;
  real_T c1_f_x;
  int32_T c1_i92;
  real_T c1_e_A[32];
  int32_T c1_ix0;
  int32_T c1_j;
  int32_T c1_c_k;
  real_T c1_e_y;
  real_T c1_f_y;
  int32_T c1_qp1jj;
  int32_T c1_f_ii;
  real_T c1_b_e[4];
  real_T c1_g_x;
  real_T c1_f_A;
  int32_T c1_i93;
  int32_T c1_i94;
  real_T c1_b_U[32];
  int32_T c1_b_ix0;
  real_T c1_c_B;
  int32_T c1_g_ii;
  real_T c1_g_y;
  real_T c1_d_B;
  real_T c1_b_absx;
  real_T c1_b_t;
  real_T c1_g_A[32];
  int32_T c1_c_a;
  real_T c1_h_y;
  int32_T c1_b_j;
  real_T c1_h_x;
  int32_T c1_colq;
  real_T c1_i_x;
  real_T c1_b_d;
  real_T c1_h_A;
  int32_T c1_c;
  real_T c1_i_y;
  int32_T c1_i;
  real_T c1_j_y;
  int32_T c1_colqp1;
  real_T c1_k_y;
  int32_T c1_i95;
  real_T c1_b_Vf[16];
  int32_T c1_i96;
  real_T c1_c_U[32];
  int32_T c1_e_qp1;
  real_T c1_e_B;
  int32_T c1_b;
  real_T c1_l_y;
  real_T c1_maxval;
  real_T c1_j_x;
  int32_T c1_b_b;
  real_T c1_i_A;
  real_T c1_m_y;
  boolean_T c1_g_overflow;
  real_T c1_k_x;
  int32_T c1_b_c;
  int32_T c1_b_n;
  real_T c1_b_varargin_1;
  real_T c1_n_y;
  int32_T c1_c_b;
  real_T c1_f_B;
  real_T c1_o_y;
  int32_T c1_d_a;
  real_T c1_e_a;
  int32_T c1_b_i;
  int32_T c1_qs;
  real_T c1_kase;
  real_T c1_c_varargin_2;
  real_T c1_p_y;
  real_T c1_c_Vf[16];
  boolean_T c1_h_overflow;
  real_T c1_l_x;
  real_T c1_m_x;
  int32_T c1_d_b;
  int32_T c1_c_ix0;
  int32_T c1_b_m;
  real_T c1_test0;
  real_T c1_d_varargin_2;
  real_T c1_j_A;
  real_T c1_q_y;
  int32_T c1_c_n;
  int32_T c1_h_ii;
  real_T c1_r_y;
  int32_T c1_i97;
  int32_T c1_d_n;
  int32_T c1_h_q;
  real_T c1_ztest0;
  real_T c1_b_varargin_3;
  real_T c1_g_B;
  real_T c1_n_x;
  real_T c1_f_a;
  real_T c1_s_y;
  int32_T c1_g_a;
  real_T c1_h_a;
  int32_T c1_i_a;
  real_T c1_o_x;
  real_T c1_p_x;
  int32_T c1_i_ii;
  real_T c1_t_y;
  int32_T c1_d_ix0;
  int32_T c1_e_b;
  int32_T c1_e_ix0;
  int32_T c1_f_b;
  real_T c1_f;
  int32_T c1_mm1;
  real_T c1_u_y;
  real_T c1_v_y;
  real_T c1_w_y;
  int32_T c1_j_a;
  int32_T c1_f_ix0;
  int32_T c1_k_a;
  real_T c1_d7;
  real_T c1_q_x;
  real_T c1_r_x;
  int32_T c1_g_ix0;
  real_T c1_h_B;
  int32_T c1_g_b;
  int32_T c1_l_a;
  int32_T c1_h_b;
  int32_T c1_i98;
  real_T c1_d8;
  real_T c1_x_y;
  real_T c1_y_y;
  int32_T c1_m_a;
  real_T c1_ab_y;
  boolean_T c1_i_overflow;
  int32_T c1_c_c;
  boolean_T c1_j_overflow;
  int32_T c1_i_q;
  int32_T c1_j_q;
  real_T c1_d9;
  real_T c1_s_x;
  real_T c1_bb_y;
  int32_T c1_d_c;
  real_T c1_cb_y;
  int32_T c1_i_b;
  int32_T c1_n_a;
  int32_T c1_c_m;
  real_T c1_d10;
  real_T c1_db_y;
  int32_T c1_j_b;
  real_T c1_eb_y;
  int32_T c1_e_c;
  int32_T c1_k_b;
  int32_T c1_o_a;
  real_T c1_d11;
  int32_T c1_f_c;
  int32_T c1_e_n;
  int32_T c1_d_k;
  int32_T c1_p_a;
  int32_T c1_j_ii;
  int32_T c1_q_a;
  int32_T c1_l_b;
  real_T c1_c_varargin_1[5];
  int32_T c1_r_a;
  real_T c1_s_a;
  int32_T c1_m_b;
  int32_T c1_n_b;
  int32_T c1_t_a;
  int32_T c1_o_b;
  int32_T c1_h_ix0;
  int32_T c1_i99;
  boolean_T c1_k_overflow;
  int32_T c1_p_b;
  int32_T c1_i100;
  int32_T c1_f_n;
  int32_T c1_e_k;
  int32_T c1_u_a;
  boolean_T c1_l_overflow;
  int32_T c1_v_a;
  real_T c1_w_a;
  real_T c1_k_A;
  int32_T c1_q_b;
  int32_T c1_r_b;
  int32_T c1_i_ix0;
  real_T c1_i_B;
  int32_T c1_x_a;
  int32_T c1_f_k;
  real_T c1_scale;
  int32_T c1_y_a;
  int32_T c1_j_ix0;
  real_T c1_t_x;
  int32_T c1_s_b;
  real_T c1_test;
  int32_T c1_g_k;
  real_T c1_l_A;
  int32_T c1_t_b;
  int32_T c1_ab_a;
  real_T c1_fb_y;
  boolean_T c1_m_overflow;
  real_T c1_j_B;
  boolean_T c1_n_overflow;
  int32_T c1_g_c;
  real_T c1_u_x;
  real_T c1_v_x;
  int32_T c1_u_b;
  real_T c1_gb_y;
  real_T c1_t1;
  real_T c1_hb_y;
  int32_T c1_h_c;
  real_T c1_ib_y;
  int32_T c1_h_k;
  real_T c1_b_t1;
  real_T c1_w_x;
  int32_T c1_i_k;
  int32_T c1_bb_a;
  real_T c1_ztest;
  real_T c1_b_f;
  real_T c1_c_t1;
  real_T c1_jb_y;
  int32_T c1_v_b;
  real_T c1_cs;
  real_T c1_sn;
  real_T c1_unusedU0;
  real_T c1_sm;
  int32_T c1_i101;
  int32_T c1_j_k;
  real_T c1_b_cs;
  real_T c1_b_sn;
  real_T c1_m_A;
  int32_T c1_k_k;
  int32_T c1_cb_a;
  real_T c1_k_B;
  real_T c1_n_A;
  int32_T c1_w_b;
  real_T c1_c_cs;
  real_T c1_x_x;
  real_T c1_l_B;
  int32_T c1_db_a;
  real_T c1_c_sn;
  real_T c1_kb_y;
  real_T c1_y_x;
  int32_T c1_x_b;
  real_T c1_ab_x;
  int32_T c1_f_qp1;
  real_T c1_lb_y;
  boolean_T c1_o_overflow;
  real_T c1_mb_y;
  boolean_T c1_p_overflow;
  real_T c1_bb_x;
  int32_T c1_km1;
  real_T c1_smm1;
  real_T c1_nb_y;
  int32_T c1_colk;
  real_T c1_o_A;
  real_T c1_ob_y;
  int32_T c1_l_k;
  int32_T c1_colm;
  int32_T c1_colqm1;
  real_T c1_m_B;
  int32_T c1_k_ii;
  real_T c1_cb_x;
  real_T c1_pb_y;
  int32_T c1_m_k;
  real_T c1_db_x;
  int32_T c1_g_qp1;
  real_T c1_qb_y;
  boolean_T c1_q_overflow;
  real_T c1_emm1;
  real_T c1_p_A;
  real_T c1_n_B;
  int32_T c1_e_jj;
  real_T c1_eb_x;
  real_T c1_rb_y;
  real_T c1_fb_x;
  int32_T c1_h_qp1;
  real_T c1_sb_y;
  boolean_T c1_r_overflow;
  real_T c1_sqds;
  int32_T c1_i102;
  real_T c1_q_A;
  real_T c1_o_B;
  int32_T c1_f_jj;
  real_T c1_gb_x;
  real_T c1_r_A[32];
  real_T c1_tb_y;
  real_T c1_hb_x;
  real_T c1_ub_y;
  real_T c1_s_A;
  real_T c1_eqds;
  real_T c1_p_B;
  real_T c1_t_A;
  real_T c1_ib_x;
  real_T c1_jb_x;
  real_T c1_vb_y;
  real_T c1_kb_x;
  real_T c1_lb_x;
  real_T c1_y_b;
  real_T c1_wb_y;
  real_T c1_i_c;
  int32_T c1_i103;
  real_T c1_shift;
  real_T c1_b_work[8];
  real_T c1_g;
  int32_T c1_k_q;
  real_T c1_u_A;
  int32_T c1_b_mm1;
  real_T c1_q_B;
  int32_T c1_eb_a;
  real_T c1_mb_x;
  int32_T c1_ab_b;
  real_T c1_xb_y;
  int32_T c1_fb_a;
  real_T c1_nb_x;
  int32_T c1_bb_b;
  real_T c1_yb_y;
  boolean_T c1_s_overflow;
  int32_T c1_n_k;
  int32_T c1_kp1;
  real_T c1_c_f;
  real_T c1_unusedU1;
  real_T c1_d_cs;
  real_T c1_d_sn;
  int32_T c1_colkp1;
  real_T c1_d_f;
  real_T c1_unusedU2;
  real_T c1_e_cs;
  real_T c1_e_sn;
  boolean_T guard1 = false;
  boolean_T guard2 = false;
  boolean_T guard3 = false;
  boolean_T guard4 = false;
  boolean_T exitg1;
  boolean_T exitg2;
  boolean_T exitg3;
  boolean_T exitg4;
  boolean_T guard11 = false;
  for (c1_i82 = 0; c1_i82 < 4; c1_i82++) {
    c1_b_s[c1_i82] = 0.0;
  }

  for (c1_i83 = 0; c1_i83 < 4; c1_i83++) {
    c1_e[c1_i83] = 0.0;
  }

  for (c1_i84 = 0; c1_i84 < 8; c1_i84++) {
    c1_work[c1_i84] = 0.0;
  }

  for (c1_i85 = 0; c1_i85 < 32; c1_i85++) {
    c1_U[c1_i85] = 0.0;
  }

  for (c1_i86 = 0; c1_i86 < 16; c1_i86++) {
    c1_Vf[c1_i86] = 0.0;
  }

  for (c1_q = 1; c1_q < 5; c1_q++) {
    c1_b_q = c1_q - 1;
    c1_qp1 = c1_b_q + 2;
    c1_qm1 = c1_b_q;
    c1_qq = (c1_b_q + (c1_qm1 << 3)) + 1;
    c1_nmq = 7 - c1_b_q;
    c1_nmqp1 = c1_nmq + 1;
    c1_apply_transform = false;
    if (c1_b_q + 1 <= 4) {
      for (c1_i87 = 0; c1_i87 < 32; c1_i87++) {
        c1_b_A[c1_i87] = c1_A[c1_i87];
      }

      c1_nrm = c1_xnrm2(chartInstance, c1_nmqp1, c1_b_A, c1_qq);
      if (c1_nrm > 0.0) {
        c1_apply_transform = true;
        c1_absx = c1_nrm;
        c1_d = c1_A[c1_qq - 1];
        if (c1_d < 0.0) {
          c1_y = -c1_absx;
        } else {
          c1_y = c1_absx;
        }

        c1_b_s[c1_b_q] = c1_y;
        c1_n = c1_nmqp1;
        c1_b_a = c1_b_s[c1_b_q];
        c1_ix0 = c1_qq;
        if (c1_abs(chartInstance, c1_b_a) >= 1.0020841800044864E-292) {
          c1_c_B = c1_b_a;
          c1_h_y = c1_c_B;
          c1_i_y = c1_h_y;
          c1_l_y = 1.0 / c1_i_y;
          c1_b_n = c1_n;
          c1_e_a = c1_l_y;
          c1_c_ix0 = c1_ix0;
          c1_d_n = c1_b_n;
          c1_h_a = c1_e_a;
          c1_e_ix0 = c1_c_ix0;
          c1_f_ix0 = c1_e_ix0;
          c1_l_a = c1_d_n;
          c1_c_c = c1_l_a;
          c1_i_b = c1_c_c - 1;
          c1_e_c = c1_i_b;
          c1_p_a = c1_e_ix0;
          c1_m_b = c1_e_c;
          c1_i99 = c1_p_a + c1_m_b;
          c1_u_a = c1_f_ix0;
          c1_q_b = c1_i99;
          c1_x_a = c1_u_a;
          c1_s_b = c1_q_b;
          c1_m_overflow = ((!(c1_x_a > c1_s_b)) && (c1_s_b > 2147483646));
          if (c1_m_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_m_overflow);
          }

          for (c1_h_k = c1_f_ix0; c1_h_k <= c1_i99; c1_h_k++) {
            c1_j_k = c1_h_k - 1;
            c1_A[c1_j_k] *= c1_h_a;
          }
        } else {
          c1_b_ix0 = c1_ix0;
          c1_c_a = c1_n;
          c1_c = c1_c_a;
          c1_b = c1_c - 1;
          c1_b_c = c1_b;
          c1_d_a = c1_ix0;
          c1_d_b = c1_b_c;
          c1_i97 = c1_d_a + c1_d_b;
          c1_g_a = c1_b_ix0;
          c1_e_b = c1_i97;
          c1_j_a = c1_g_a;
          c1_g_b = c1_e_b;
          c1_i_overflow = ((!(c1_j_a > c1_g_b)) && (c1_g_b > 2147483646));
          if (c1_i_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_i_overflow);
          }

          for (c1_d_k = c1_b_ix0; c1_d_k <= c1_i97; c1_d_k++) {
            c1_e_k = c1_d_k - 1;
            c1_k_A = c1_A[c1_e_k];
            c1_i_B = c1_b_a;
            c1_t_x = c1_k_A;
            c1_fb_y = c1_i_B;
            c1_u_x = c1_t_x;
            c1_gb_y = c1_fb_y;
            c1_ib_y = c1_u_x / c1_gb_y;
            c1_A[c1_e_k] = c1_ib_y;
          }
        }

        c1_A[c1_qq - 1]++;
        c1_b_s[c1_b_q] = -c1_b_s[c1_b_q];
      } else {
        c1_b_s[c1_b_q] = 0.0;
      }
    }

    c1_b_qp1 = c1_qp1;
    c1_overflow = false;
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_jj = c1_b_qp1; c1_jj < 5; c1_jj++) {
      c1_c_jj = c1_jj - 1;
      c1_qjj = (c1_b_q + (c1_c_jj << 3)) + 1;
      if (c1_apply_transform) {
        for (c1_i88 = 0; c1_i88 < 32; c1_i88++) {
          c1_e_A[c1_i88] = c1_A[c1_i88];
        }

        for (c1_i92 = 0; c1_i92 < 32; c1_i92++) {
          c1_g_A[c1_i92] = c1_A[c1_i92];
        }

        c1_b_t = c1_xdotc(chartInstance, c1_nmqp1, c1_e_A, c1_qq, c1_g_A, c1_qjj);
        c1_h_A = c1_b_t;
        c1_e_B = c1_A[c1_b_q + (c1_b_q << 3)];
        c1_k_x = c1_h_A;
        c1_o_y = c1_e_B;
        c1_m_x = c1_k_x;
        c1_r_y = c1_o_y;
        c1_s_y = c1_m_x / c1_r_y;
        c1_b_t = -c1_s_y;
        c1_e_xaxpy(chartInstance, c1_nmqp1, c1_b_t, c1_qq, c1_A, c1_qjj);
      }

      c1_e[c1_c_jj] = c1_A[c1_qjj - 1];
    }

    if (c1_b_q + 1 <= 4) {
      c1_f_q = c1_b_q + 1;
      c1_d_overflow = false;
      if (c1_d_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_d_overflow);
      }

      for (c1_e_ii = c1_f_q; c1_e_ii < 9; c1_e_ii++) {
        c1_d_ii = c1_e_ii - 1;
        c1_U[c1_d_ii + (c1_b_q << 3)] = c1_A[c1_d_ii + (c1_b_q << 3)];
      }
    }

    if (c1_b_q + 1 <= 2) {
      c1_pmq = 3 - c1_b_q;
      for (c1_i89 = 0; c1_i89 < 4; c1_i89++) {
        c1_b_e[c1_i89] = c1_e[c1_i89];
      }

      c1_nrm = c1_b_xnrm2(chartInstance, c1_pmq, c1_b_e, c1_qp1);
      if (c1_nrm == 0.0) {
        c1_e[c1_b_q] = 0.0;
      } else {
        c1_b_absx = c1_nrm;
        c1_b_d = c1_e[c1_qp1 - 1];
        if (c1_b_d < 0.0) {
          c1_m_y = -c1_b_absx;
        } else {
          c1_m_y = c1_b_absx;
        }

        c1_e[c1_b_q] = c1_m_y;
        c1_c_n = c1_pmq;
        c1_f_a = c1_e[c1_b_q];
        c1_d_ix0 = c1_qp1;
        if (c1_abs(chartInstance, c1_f_a) >= 1.0020841800044864E-292) {
          c1_h_B = c1_f_a;
          c1_ab_y = c1_h_B;
          c1_cb_y = c1_ab_y;
          c1_eb_y = 1.0 / c1_cb_y;
          c1_e_n = c1_c_n;
          c1_s_a = c1_eb_y;
          c1_h_ix0 = c1_d_ix0;
          c1_f_n = c1_e_n;
          c1_w_a = c1_s_a;
          c1_i_ix0 = c1_h_ix0;
          c1_j_ix0 = c1_i_ix0;
          c1_ab_a = c1_f_n;
          c1_g_c = c1_ab_a;
          c1_u_b = c1_g_c - 1;
          c1_h_c = c1_u_b;
          c1_bb_a = c1_i_ix0;
          c1_v_b = c1_h_c;
          c1_i101 = c1_bb_a + c1_v_b;
          c1_cb_a = c1_j_ix0;
          c1_w_b = c1_i101;
          c1_db_a = c1_cb_a;
          c1_x_b = c1_w_b;
          c1_o_overflow = ((!(c1_db_a > c1_x_b)) && (c1_x_b > 2147483646));
          if (c1_o_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_o_overflow);
          }

          for (c1_l_k = c1_j_ix0; c1_l_k <= c1_i101; c1_l_k++) {
            c1_m_k = c1_l_k - 1;
            c1_e[c1_m_k] *= c1_w_a;
          }
        } else {
          c1_g_ix0 = c1_d_ix0;
          c1_m_a = c1_c_n;
          c1_d_c = c1_m_a;
          c1_j_b = c1_d_c - 1;
          c1_f_c = c1_j_b;
          c1_r_a = c1_d_ix0;
          c1_o_b = c1_f_c;
          c1_i100 = c1_r_a + c1_o_b;
          c1_v_a = c1_g_ix0;
          c1_r_b = c1_i100;
          c1_y_a = c1_v_a;
          c1_t_b = c1_r_b;
          c1_n_overflow = ((!(c1_y_a > c1_t_b)) && (c1_t_b > 2147483646));
          if (c1_n_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_n_overflow);
          }

          for (c1_i_k = c1_g_ix0; c1_i_k <= c1_i100; c1_i_k++) {
            c1_k_k = c1_i_k - 1;
            c1_n_A = c1_e[c1_k_k];
            c1_l_B = c1_f_a;
            c1_y_x = c1_n_A;
            c1_lb_y = c1_l_B;
            c1_bb_x = c1_y_x;
            c1_nb_y = c1_lb_y;
            c1_ob_y = c1_bb_x / c1_nb_y;
            c1_e[c1_k_k] = c1_ob_y;
          }
        }

        c1_e[c1_qp1 - 1]++;
        c1_e[c1_b_q] = -c1_e[c1_b_q];
        if (c1_qp1 <= 8) {
          c1_f_qp1 = c1_qp1;
          c1_p_overflow = false;
          if (c1_p_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_p_overflow);
          }

          for (c1_k_ii = c1_f_qp1; c1_k_ii < 9; c1_k_ii++) {
            c1_d_ii = c1_k_ii - 1;
            c1_work[c1_d_ii] = 0.0;
          }

          c1_g_qp1 = c1_qp1;
          c1_q_overflow = false;
          if (c1_q_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_q_overflow);
          }

          for (c1_e_jj = c1_g_qp1; c1_e_jj < 5; c1_e_jj++) {
            c1_c_jj = c1_e_jj - 1;
            c1_qp1jj = c1_qp1 + (c1_c_jj << 3);
            for (c1_i102 = 0; c1_i102 < 32; c1_i102++) {
              c1_r_A[c1_i102] = c1_A[c1_i102];
            }

            c1_f_xaxpy(chartInstance, c1_nmq, c1_e[c1_c_jj], c1_r_A, c1_qp1jj,
                       c1_work, c1_qp1);
          }

          c1_h_qp1 = c1_qp1;
          c1_r_overflow = false;
          if (c1_r_overflow) {
            c1_check_forloop_overflow_error(chartInstance, c1_r_overflow);
          }

          for (c1_f_jj = c1_h_qp1; c1_f_jj < 5; c1_f_jj++) {
            c1_c_jj = c1_f_jj - 1;
            c1_s_A = -c1_e[c1_c_jj];
            c1_p_B = c1_e[c1_qp1 - 1];
            c1_ib_x = c1_s_A;
            c1_vb_y = c1_p_B;
            c1_lb_x = c1_ib_x;
            c1_wb_y = c1_vb_y;
            c1_b_t = c1_lb_x / c1_wb_y;
            c1_qp1jj = c1_qp1 + (c1_c_jj << 3);
            for (c1_i103 = 0; c1_i103 < 8; c1_i103++) {
              c1_b_work[c1_i103] = c1_work[c1_i103];
            }

            c1_g_xaxpy(chartInstance, c1_nmq, c1_b_t, c1_b_work, c1_qp1, c1_A,
                       c1_qp1jj);
          }
        }
      }

      c1_e_qp1 = c1_qp1;
      c1_g_overflow = false;
      if (c1_g_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_g_overflow);
      }

      for (c1_h_ii = c1_e_qp1; c1_h_ii < 5; c1_h_ii++) {
        c1_d_ii = c1_h_ii - 1;
        c1_Vf[c1_d_ii + (c1_b_q << 2)] = c1_e[c1_d_ii];
      }
    }
  }

  c1_m = 3;
  c1_e[2] = c1_A[26];
  c1_e[3] = 0.0;
  for (c1_c_q = 4; c1_c_q > 0; c1_c_q--) {
    c1_b_q = c1_c_q - 1;
    c1_qp1 = c1_b_q + 1;
    c1_nmq = 8 - c1_b_q;
    c1_nmqp1 = c1_nmq;
    c1_qq = c1_b_q + (c1_b_q << 3);
    if (c1_b_s[c1_b_q] != 0.0) {
      c1_c_qp1 = c1_qp1 + 1;
      c1_b_overflow = false;
      if (c1_b_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_b_overflow);
      }

      for (c1_b_jj = c1_c_qp1; c1_b_jj < 5; c1_b_jj++) {
        c1_c_jj = c1_b_jj - 1;
        c1_qjj = (c1_b_q + (c1_c_jj << 3)) + 1;
        for (c1_i91 = 0; c1_i91 < 32; c1_i91++) {
          c1_b_U[c1_i91] = c1_U[c1_i91];
        }

        for (c1_i94 = 0; c1_i94 < 32; c1_i94++) {
          c1_c_U[c1_i94] = c1_U[c1_i94];
        }

        c1_b_t = c1_xdotc(chartInstance, c1_nmqp1, c1_b_U, c1_qq + 1, c1_c_U,
                          c1_qjj);
        c1_i_A = c1_b_t;
        c1_f_B = c1_U[c1_qq];
        c1_l_x = c1_i_A;
        c1_q_y = c1_f_B;
        c1_n_x = c1_l_x;
        c1_t_y = c1_q_y;
        c1_w_y = c1_n_x / c1_t_y;
        c1_b_t = -c1_w_y;
        c1_e_xaxpy(chartInstance, c1_nmqp1, c1_b_t, c1_qq + 1, c1_U, c1_qjj);
      }

      c1_g_q = c1_b_q + 1;
      c1_e_overflow = false;
      if (c1_e_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_e_overflow);
      }

      for (c1_f_ii = c1_g_q; c1_f_ii < 9; c1_f_ii++) {
        c1_d_ii = c1_f_ii - 1;
        c1_U[c1_d_ii + (c1_b_q << 3)] = -c1_U[c1_d_ii + (c1_b_q << 3)];
      }

      c1_U[c1_qq]++;
      c1_i96 = c1_b_q;
      c1_b_b = c1_i96;
      c1_c_b = c1_b_b;
      c1_h_overflow = ((!(1 > c1_c_b)) && (c1_c_b > 2147483646));
      if (c1_h_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_h_overflow);
      }

      for (c1_i_ii = 1; c1_i_ii <= c1_i96; c1_i_ii++) {
        c1_d_ii = c1_i_ii - 1;
        c1_U[c1_d_ii + (c1_b_q << 3)] = 0.0;
      }
    } else {
      for (c1_ii = 1; c1_ii < 9; c1_ii++) {
        c1_d_ii = c1_ii - 1;
        c1_U[c1_d_ii + (c1_b_q << 3)] = 0.0;
      }

      c1_U[c1_qq] = 1.0;
    }
  }

  for (c1_d_q = 4; c1_d_q > 0; c1_d_q--) {
    c1_b_q = c1_d_q - 1;
    if (c1_b_q + 1 <= 2) {
      if (c1_e[c1_b_q] != 0.0) {
        c1_qp1 = c1_b_q + 2;
        c1_pmq = 3 - c1_b_q;
        c1_qp1q = c1_qp1 + (c1_b_q << 2);
        c1_d_qp1 = c1_qp1;
        c1_c_overflow = false;
        if (c1_c_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_c_overflow);
        }

        for (c1_d_jj = c1_d_qp1; c1_d_jj < 5; c1_d_jj++) {
          c1_c_jj = c1_d_jj - 1;
          c1_qp1jj = c1_qp1 + (c1_c_jj << 2);
          for (c1_i93 = 0; c1_i93 < 16; c1_i93++) {
            c1_b_Vf[c1_i93] = c1_Vf[c1_i93];
          }

          for (c1_i95 = 0; c1_i95 < 16; c1_i95++) {
            c1_c_Vf[c1_i95] = c1_Vf[c1_i95];
          }

          c1_b_t = c1_b_xdotc(chartInstance, c1_pmq, c1_b_Vf, c1_qp1q, c1_c_Vf,
                              c1_qp1jj);
          c1_j_A = c1_b_t;
          c1_g_B = c1_Vf[c1_qp1q - 1];
          c1_p_x = c1_j_A;
          c1_v_y = c1_g_B;
          c1_r_x = c1_p_x;
          c1_y_y = c1_v_y;
          c1_bb_y = c1_r_x / c1_y_y;
          c1_b_t = -c1_bb_y;
          c1_h_xaxpy(chartInstance, c1_pmq, c1_b_t, c1_qp1q, c1_Vf, c1_qp1jj);
        }
      }
    }

    for (c1_b_ii = 1; c1_b_ii < 5; c1_b_ii++) {
      c1_d_ii = c1_b_ii - 1;
      c1_Vf[c1_d_ii + (c1_b_q << 2)] = 0.0;
    }

    c1_Vf[c1_b_q + (c1_b_q << 2)] = 1.0;
  }

  for (c1_e_q = 1; c1_e_q < 5; c1_e_q++) {
    c1_b_q = c1_e_q - 1;
    if (c1_b_s[c1_b_q] != 0.0) {
      c1_rt = c1_abs(chartInstance, c1_b_s[c1_b_q]);
      c1_c_A = c1_b_s[c1_b_q];
      c1_B = c1_rt;
      c1_b_x = c1_c_A;
      c1_b_y = c1_B;
      c1_c_x = c1_b_x;
      c1_c_y = c1_b_y;
      c1_r = c1_c_x / c1_c_y;
      c1_b_s[c1_b_q] = c1_rt;
      if (c1_b_q + 1 < 4) {
        c1_f_A = c1_e[c1_b_q];
        c1_d_B = c1_r;
        c1_i_x = c1_f_A;
        c1_k_y = c1_d_B;
        c1_j_x = c1_i_x;
        c1_n_y = c1_k_y;
        c1_p_y = c1_j_x / c1_n_y;
        c1_e[c1_b_q] = c1_p_y;
      }

      if (c1_b_q + 1 <= 8) {
        c1_colq = c1_b_q << 3;
        c1_c_xscal(chartInstance, c1_r, c1_U, c1_colq + 1);
      }
    }

    if (c1_b_q + 1 < 4) {
      if (c1_e[c1_b_q] != 0.0) {
        c1_rt = c1_abs(chartInstance, c1_e[c1_b_q]);
        c1_d_A = c1_rt;
        c1_b_B = c1_e[c1_b_q];
        c1_d_x = c1_d_A;
        c1_d_y = c1_b_B;
        c1_f_x = c1_d_x;
        c1_f_y = c1_d_y;
        c1_r = c1_f_x / c1_f_y;
        c1_e[c1_b_q] = c1_rt;
        c1_b_s[c1_b_q + 1] *= c1_r;
        c1_colqp1 = (c1_b_q + 1) << 2;
        c1_d_xscal(chartInstance, c1_r, c1_Vf, c1_colqp1 + 1);
      }
    }
  }

  c1_iter = 0.0;
  c1_snorm = 0.0;
  for (c1_c_ii = 1; c1_c_ii < 5; c1_c_ii++) {
    c1_d_ii = c1_c_ii - 1;
    c1_varargin_1 = c1_abs(chartInstance, c1_b_s[c1_d_ii]);
    c1_varargin_2 = c1_abs(chartInstance, c1_e[c1_d_ii]);
    c1_b_varargin_2 = c1_varargin_1;
    c1_varargin_3 = c1_varargin_2;
    c1_e_x = c1_b_varargin_2;
    c1_e_y = c1_varargin_3;
    c1_g_x = c1_e_x;
    c1_g_y = c1_e_y;
    c1_h_x = c1_g_x;
    c1_j_y = c1_g_y;
    c1_maxval = muDoubleScalarMax(c1_h_x, c1_j_y);
    c1_b_varargin_1 = c1_snorm;
    c1_c_varargin_2 = c1_maxval;
    c1_d_varargin_2 = c1_b_varargin_1;
    c1_b_varargin_3 = c1_c_varargin_2;
    c1_o_x = c1_d_varargin_2;
    c1_u_y = c1_b_varargin_3;
    c1_q_x = c1_o_x;
    c1_x_y = c1_u_y;
    c1_s_x = c1_q_x;
    c1_db_y = c1_x_y;
    c1_snorm = muDoubleScalarMax(c1_s_x, c1_db_y);
  }

  exitg1 = false;
  while ((exitg1 == false) && (c1_m + 1 > 0)) {
    if (c1_iter >= 75.0) {
      c1_b_error(chartInstance);
      exitg1 = true;
    } else {
      c1_b_q = c1_m;
      c1_i90 = c1_m;
      c1_f_overflow = false;
      if (c1_f_overflow) {
        c1_check_forloop_overflow_error(chartInstance, c1_f_overflow);
      }

      c1_g_ii = c1_i90;
      guard3 = false;
      guard4 = false;
      exitg4 = false;
      while ((exitg4 == false) && (c1_g_ii > -1)) {
        c1_d_ii = c1_g_ii;
        c1_b_q = c1_d_ii;
        if (c1_d_ii == 0) {
          exitg4 = true;
        } else {
          c1_test0 = c1_abs(chartInstance, c1_b_s[c1_d_ii - 1]) + c1_abs
            (chartInstance, c1_b_s[c1_d_ii]);
          c1_ztest0 = c1_abs(chartInstance, c1_e[c1_d_ii - 1]);
          if (c1_ztest0 <= 2.2204460492503131E-16 * c1_test0) {
            guard4 = true;
            exitg4 = true;
          } else if (c1_ztest0 <= 1.0020841800044864E-292) {
            guard4 = true;
            exitg4 = true;
          } else {
            guard11 = false;
            if (c1_iter > 20.0) {
              if (c1_ztest0 <= 2.2204460492503131E-16 * c1_snorm) {
                guard3 = true;
                exitg4 = true;
              } else {
                guard11 = true;
              }
            } else {
              guard11 = true;
            }

            if (guard11 == true) {
              c1_g_ii--;
              guard3 = false;
              guard4 = false;
            }
          }
        }
      }

      if (guard4 == true) {
        guard3 = true;
      }

      if (guard3 == true) {
        c1_e[c1_d_ii - 1] = 0.0;
      }

      if (c1_b_q == c1_m) {
        c1_kase = 4.0;
      } else {
        c1_qs = c1_m + 1;
        c1_b_m = c1_m + 1;
        c1_h_q = c1_b_q;
        c1_i_a = c1_b_m;
        c1_f_b = c1_h_q;
        c1_k_a = c1_i_a;
        c1_h_b = c1_f_b;
        c1_j_overflow = ((!(c1_k_a < c1_h_b)) && (c1_h_b < -2147483647));
        if (c1_j_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_j_overflow);
        }

        c1_j_ii = c1_b_m;
        guard2 = false;
        exitg3 = false;
        while ((exitg3 == false) && (c1_j_ii >= c1_h_q)) {
          c1_d_ii = c1_j_ii;
          c1_qs = c1_d_ii;
          if (c1_d_ii == c1_b_q) {
            exitg3 = true;
          } else {
            c1_test = 0.0;
            if (c1_d_ii < c1_m + 1) {
              c1_test = c1_abs(chartInstance, c1_e[c1_d_ii - 1]);
            }

            if (c1_d_ii > c1_b_q + 1) {
              c1_test += c1_abs(chartInstance, c1_e[c1_d_ii - 2]);
            }

            c1_ztest = c1_abs(chartInstance, c1_b_s[c1_d_ii - 1]);
            if (c1_ztest <= 2.2204460492503131E-16 * c1_test) {
              guard2 = true;
              exitg3 = true;
            } else if (c1_ztest <= 1.0020841800044864E-292) {
              guard2 = true;
              exitg3 = true;
            } else {
              c1_j_ii--;
              guard2 = false;
            }
          }
        }

        if (guard2 == true) {
          c1_b_s[c1_d_ii - 1] = 0.0;
        }

        if (c1_qs == c1_b_q) {
          c1_kase = 3.0;
        } else if (c1_qs == c1_m + 1) {
          c1_kase = 1.0;
        } else {
          c1_kase = 2.0;
          c1_b_q = c1_qs;
        }
      }

      c1_b_q;
      switch ((int32_T)c1_kase) {
       case 1:
        c1_f = c1_e[c1_m - 1];
        c1_e[c1_m - 1] = 0.0;
        c1_i98 = c1_m;
        c1_i_q = c1_b_q + 1;
        c1_n_a = c1_i98;
        c1_k_b = c1_i_q;
        c1_q_a = c1_n_a;
        c1_n_b = c1_k_b;
        c1_k_overflow = ((!(c1_q_a < c1_n_b)) && (c1_n_b < -2147483647));
        if (c1_k_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_k_overflow);
        }

        for (c1_f_k = c1_i98; c1_f_k >= c1_i_q; c1_f_k--) {
          c1_c_k = c1_f_k - 1;
          c1_t1 = c1_b_s[c1_c_k];
          c1_b_t1 = c1_t1;
          c1_b_f = c1_f;
          c1_b_xrotg(chartInstance, &c1_b_t1, &c1_b_f, &c1_cs, &c1_sn);
          c1_t1 = c1_b_t1;
          c1_f = c1_b_f;
          c1_c_cs = c1_cs;
          c1_c_sn = c1_sn;
          c1_b_s[c1_c_k] = c1_t1;
          if (c1_c_k + 1 > c1_b_q + 1) {
            c1_km1 = c1_c_k - 1;
            c1_f = -c1_c_sn * c1_e[c1_km1];
            c1_e[c1_km1] *= c1_c_cs;
          }

          c1_colk = c1_c_k << 2;
          c1_colm = c1_m << 2;
          c1_c_xrot(chartInstance, c1_Vf, c1_colk + 1, c1_colm + 1, c1_c_cs,
                    c1_c_sn);
        }
        break;

       case 2:
        c1_qm1 = c1_b_q - 1;
        c1_f = c1_e[c1_qm1];
        c1_e[c1_qm1] = 0.0;
        c1_j_q = c1_b_q + 1;
        c1_c_m = c1_m + 1;
        c1_o_a = c1_j_q;
        c1_l_b = c1_c_m;
        c1_t_a = c1_o_a;
        c1_p_b = c1_l_b;
        c1_l_overflow = ((!(c1_t_a > c1_p_b)) && (c1_p_b > 2147483646));
        if (c1_l_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_l_overflow);
        }

        for (c1_g_k = c1_j_q; c1_g_k <= c1_c_m; c1_g_k++) {
          c1_c_k = c1_g_k - 1;
          c1_t1 = c1_b_s[c1_c_k];
          c1_c_t1 = c1_t1;
          c1_unusedU0 = c1_f;
          c1_b_xrotg(chartInstance, &c1_c_t1, &c1_unusedU0, &c1_b_cs, &c1_b_sn);
          c1_t1 = c1_c_t1;
          c1_c_cs = c1_b_cs;
          c1_c_sn = c1_b_sn;
          c1_b_s[c1_c_k] = c1_t1;
          c1_f = -c1_c_sn * c1_e[c1_c_k];
          c1_e[c1_c_k] *= c1_c_cs;
          c1_colk = c1_c_k << 3;
          c1_colqm1 = c1_qm1 << 3;
          c1_d_xrot(chartInstance, c1_U, c1_colk + 1, c1_colqm1 + 1, c1_c_cs,
                    c1_c_sn);
        }
        break;

       case 3:
        c1_mm1 = c1_m - 1;
        c1_d7 = c1_abs(chartInstance, c1_b_s[c1_m]);
        c1_d8 = c1_abs(chartInstance, c1_b_s[c1_mm1]);
        c1_d9 = c1_abs(chartInstance, c1_e[c1_mm1]);
        c1_d10 = c1_abs(chartInstance, c1_b_s[c1_b_q]);
        c1_d11 = c1_abs(chartInstance, c1_e[c1_b_q]);
        c1_c_varargin_1[0] = c1_d7;
        c1_c_varargin_1[1] = c1_d8;
        c1_c_varargin_1[2] = c1_d9;
        c1_c_varargin_1[3] = c1_d10;
        c1_c_varargin_1[4] = c1_d11;
        c1_scale = c1_eml_extremum(chartInstance, c1_c_varargin_1);
        c1_l_A = c1_b_s[c1_m];
        c1_j_B = c1_scale;
        c1_v_x = c1_l_A;
        c1_hb_y = c1_j_B;
        c1_w_x = c1_v_x;
        c1_jb_y = c1_hb_y;
        c1_sm = c1_w_x / c1_jb_y;
        c1_m_A = c1_b_s[c1_mm1];
        c1_k_B = c1_scale;
        c1_x_x = c1_m_A;
        c1_kb_y = c1_k_B;
        c1_ab_x = c1_x_x;
        c1_mb_y = c1_kb_y;
        c1_smm1 = c1_ab_x / c1_mb_y;
        c1_o_A = c1_e[c1_mm1];
        c1_m_B = c1_scale;
        c1_cb_x = c1_o_A;
        c1_pb_y = c1_m_B;
        c1_db_x = c1_cb_x;
        c1_qb_y = c1_pb_y;
        c1_emm1 = c1_db_x / c1_qb_y;
        c1_p_A = c1_b_s[c1_b_q];
        c1_n_B = c1_scale;
        c1_eb_x = c1_p_A;
        c1_rb_y = c1_n_B;
        c1_fb_x = c1_eb_x;
        c1_sb_y = c1_rb_y;
        c1_sqds = c1_fb_x / c1_sb_y;
        c1_q_A = c1_e[c1_b_q];
        c1_o_B = c1_scale;
        c1_gb_x = c1_q_A;
        c1_tb_y = c1_o_B;
        c1_hb_x = c1_gb_x;
        c1_ub_y = c1_tb_y;
        c1_eqds = c1_hb_x / c1_ub_y;
        c1_t_A = (c1_smm1 + c1_sm) * (c1_smm1 - c1_sm) + c1_emm1 * c1_emm1;
        c1_jb_x = c1_t_A;
        c1_kb_x = c1_jb_x;
        c1_y_b = c1_kb_x / 2.0;
        c1_i_c = c1_sm * c1_emm1;
        c1_i_c *= c1_i_c;
        guard1 = false;
        if (c1_y_b != 0.0) {
          guard1 = true;
        } else if (c1_i_c != 0.0) {
          guard1 = true;
        } else {
          c1_shift = 0.0;
        }

        if (guard1 == true) {
          c1_shift = c1_y_b * c1_y_b + c1_i_c;
          c1_b_sqrt(chartInstance, &c1_shift);
          if (c1_y_b < 0.0) {
            c1_shift = -c1_shift;
          }

          c1_u_A = c1_i_c;
          c1_q_B = c1_y_b + c1_shift;
          c1_mb_x = c1_u_A;
          c1_xb_y = c1_q_B;
          c1_nb_x = c1_mb_x;
          c1_yb_y = c1_xb_y;
          c1_shift = c1_nb_x / c1_yb_y;
        }

        c1_f = (c1_sqds + c1_sm) * (c1_sqds - c1_sm) + c1_shift;
        c1_g = c1_sqds * c1_eqds;
        c1_k_q = c1_b_q + 1;
        c1_b_mm1 = c1_mm1 + 1;
        c1_eb_a = c1_k_q;
        c1_ab_b = c1_b_mm1;
        c1_fb_a = c1_eb_a;
        c1_bb_b = c1_ab_b;
        c1_s_overflow = ((!(c1_fb_a > c1_bb_b)) && (c1_bb_b > 2147483646));
        if (c1_s_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_s_overflow);
        }

        for (c1_n_k = c1_k_q; c1_n_k <= c1_b_mm1; c1_n_k++) {
          c1_c_k = c1_n_k - 1;
          c1_km1 = c1_c_k - 1;
          c1_kp1 = c1_c_k + 1;
          c1_c_f = c1_f;
          c1_unusedU1 = c1_g;
          c1_b_xrotg(chartInstance, &c1_c_f, &c1_unusedU1, &c1_d_cs, &c1_d_sn);
          c1_f = c1_c_f;
          c1_c_cs = c1_d_cs;
          c1_c_sn = c1_d_sn;
          if (c1_c_k + 1 > c1_b_q + 1) {
            c1_e[c1_km1] = c1_f;
          }

          c1_f = c1_c_cs * c1_b_s[c1_c_k] + c1_c_sn * c1_e[c1_c_k];
          c1_e[c1_c_k] = c1_c_cs * c1_e[c1_c_k] - c1_c_sn * c1_b_s[c1_c_k];
          c1_g = c1_c_sn * c1_b_s[c1_kp1];
          c1_b_s[c1_kp1] *= c1_c_cs;
          c1_colk = c1_c_k << 2;
          c1_colkp1 = (c1_c_k + 1) << 2;
          c1_c_xrot(chartInstance, c1_Vf, c1_colk + 1, c1_colkp1 + 1, c1_c_cs,
                    c1_c_sn);
          c1_d_f = c1_f;
          c1_unusedU2 = c1_g;
          c1_b_xrotg(chartInstance, &c1_d_f, &c1_unusedU2, &c1_e_cs, &c1_e_sn);
          c1_f = c1_d_f;
          c1_c_cs = c1_e_cs;
          c1_c_sn = c1_e_sn;
          c1_b_s[c1_c_k] = c1_f;
          c1_f = c1_c_cs * c1_e[c1_c_k] + c1_c_sn * c1_b_s[c1_kp1];
          c1_b_s[c1_kp1] = -c1_c_sn * c1_e[c1_c_k] + c1_c_cs * c1_b_s[c1_kp1];
          c1_g = c1_c_sn * c1_e[c1_kp1];
          c1_e[c1_kp1] *= c1_c_cs;
          if (c1_c_k + 1 < 8) {
            c1_colk = c1_c_k << 3;
            c1_colkp1 = (c1_c_k + 1) << 3;
            c1_d_xrot(chartInstance, c1_U, c1_colk + 1, c1_colkp1 + 1, c1_c_cs,
                      c1_c_sn);
          }
        }

        c1_e[c1_m - 1] = c1_f;
        c1_iter++;
        break;

       default:
        if (c1_b_s[c1_b_q] < 0.0) {
          c1_b_s[c1_b_q] = -c1_b_s[c1_b_q];
          c1_colq = c1_b_q << 2;
          c1_d_xscal(chartInstance, -1.0, c1_Vf, c1_colq + 1);
        }

        c1_qp1 = c1_b_q + 1;
        exitg2 = false;
        while ((exitg2 == false) && (c1_b_q + 1 < 4)) {
          if (c1_b_s[c1_b_q] < c1_b_s[c1_qp1]) {
            c1_rt = c1_b_s[c1_b_q];
            c1_b_s[c1_b_q] = c1_b_s[c1_qp1];
            c1_b_s[c1_qp1] = c1_rt;
            if (c1_b_q + 1 < 4) {
              c1_colq = c1_b_q << 2;
              c1_colqp1 = (c1_b_q + 1) << 2;
              c1_c_xswap(chartInstance, c1_Vf, c1_colq + 1, c1_colqp1 + 1);
            }

            if (c1_b_q + 1 < 8) {
              c1_colq = c1_b_q << 3;
              c1_colqp1 = (c1_b_q + 1) << 3;
              c1_d_xswap(chartInstance, c1_U, c1_colq + 1, c1_colqp1 + 1);
            }

            c1_b_q = c1_qp1;
            c1_qp1 = c1_b_q + 1;
          } else {
            exitg2 = true;
          }
        }

        c1_iter = 0.0;
        c1_m--;
        break;
      }
    }
  }

  for (c1_b_k = 1; c1_b_k < 5; c1_b_k++) {
    c1_c_k = c1_b_k - 1;
    c1_S[c1_c_k] = c1_b_s[c1_c_k];
  }

  for (c1_j = 1; c1_j < 5; c1_j++) {
    c1_b_j = c1_j - 1;
    for (c1_i = 1; c1_i < 5; c1_i++) {
      c1_b_i = c1_i - 1;
      c1_V[c1_b_i + (c1_b_j << 2)] = c1_Vf[c1_b_i + (c1_b_j << 2)];
    }
  }
}

static real_T c1_b_xdotc(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0)
{
  int32_T c1_i104;
  int32_T c1_i105;
  real_T c1_c_x[16];
  real_T c1_b_y[16];
  for (c1_i104 = 0; c1_i104 < 16; c1_i104++) {
    c1_c_x[c1_i104] = c1_b_x[c1_i104];
  }

  for (c1_i105 = 0; c1_i105 < 16; c1_i105++) {
    c1_b_y[c1_i105] = c1_y[c1_i105];
  }

  return c1_b_xdot(chartInstance, c1_n, c1_c_x, c1_ix0, c1_b_y, c1_iy0);
}

static real_T c1_b_xdot(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0)
{
  real_T c1_d;
  int32_T c1_b_n;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_c_n;
  int32_T c1_c_ix0;
  int32_T c1_c_iy0;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_d_n;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_b_a;
  int32_T c1_c_a;
  c1_b_n = c1_n;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_c_n = c1_b_n;
  c1_c_ix0 = c1_b_ix0;
  c1_c_iy0 = c1_b_iy0;
  c1_d = 0.0;
  if (c1_c_n < 1) {
  } else {
    c1_ix = c1_c_ix0 - 1;
    c1_iy = c1_c_iy0 - 1;
    c1_d_n = c1_c_n;
    c1_b = c1_d_n;
    c1_b_b = c1_b;
    c1_overflow = ((!(1 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 1; c1_b_k <= c1_d_n; c1_b_k++) {
      c1_d += c1_b_x[c1_ix] * c1_y[c1_iy];
      c1_b_a = c1_ix + 1;
      c1_ix = c1_b_a;
      c1_c_a = c1_iy + 1;
      c1_iy = c1_c_a;
    }
  }

  return c1_d;
}

static void c1_d_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0, real_T
  c1_b_y[16])
{
  int32_T c1_i106;
  for (c1_i106 = 0; c1_i106 < 16; c1_i106++) {
    c1_b_y[c1_i106] = c1_y[c1_i106];
  }

  c1_h_xaxpy(chartInstance, c1_n, c1_b_a, c1_ix0, c1_b_y, c1_iy0);
}

static void c1_e_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_c_x[32])
{
  int32_T c1_i107;
  for (c1_i107 = 0; c1_i107 < 32; c1_i107++) {
    c1_c_x[c1_i107] = c1_b_x[c1_i107];
  }

  c1_c_xscal(chartInstance, c1_b_a, c1_c_x, c1_ix0);
}

static void c1_b_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[16], int32_T c1_ix0, real_T c1_c_x[16])
{
  int32_T c1_i108;
  for (c1_i108 = 0; c1_i108 < 16; c1_i108++) {
    c1_c_x[c1_i108] = c1_b_x[c1_i108];
  }

  c1_d_xscal(chartInstance, c1_b_a, c1_c_x, c1_ix0);
}

static void c1_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                    c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                    real_T c1_b_s, real_T c1_c_x[16])
{
  int32_T c1_i109;
  for (c1_i109 = 0; c1_i109 < 16; c1_i109++) {
    c1_c_x[c1_i109] = c1_b_x[c1_i109];
  }

  c1_c_xrot(chartInstance, c1_c_x, c1_ix0, c1_iy0, c1_c, c1_b_s);
}

static void c1_b_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s, real_T c1_c_x[32])
{
  int32_T c1_i110;
  for (c1_i110 = 0; c1_i110 < 32; c1_i110++) {
    c1_c_x[c1_i110] = c1_b_x[c1_i110];
  }

  c1_d_xrot(chartInstance, c1_c_x, c1_ix0, c1_iy0, c1_c, c1_b_s);
}

static void c1_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c_x
                     [16])
{
  int32_T c1_i111;
  for (c1_i111 = 0; c1_i111 < 16; c1_i111++) {
    c1_c_x[c1_i111] = c1_b_x[c1_i111];
  }

  c1_c_xswap(chartInstance, c1_c_x, c1_ix0, c1_iy0);
}

static void c1_b_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c_x[32])
{
  int32_T c1_i112;
  for (c1_i112 = 0; c1_i112 < 32; c1_i112++) {
    c1_c_x[c1_i112] = c1_b_x[c1_i112];
  }

  c1_d_xswap(chartInstance, c1_c_x, c1_ix0, c1_iy0);
}

static void c1_xgemm(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
                     c1_b_k, real_T c1_A[16], real_T c1_B[32], real_T c1_C[32],
                     real_T c1_b_C[32])
{
  int32_T c1_i113;
  int32_T c1_i114;
  int32_T c1_i115;
  real_T c1_b_A[16];
  real_T c1_b_B[32];
  for (c1_i113 = 0; c1_i113 < 32; c1_i113++) {
    c1_b_C[c1_i113] = c1_C[c1_i113];
  }

  for (c1_i114 = 0; c1_i114 < 16; c1_i114++) {
    c1_b_A[c1_i114] = c1_A[c1_i114];
  }

  for (c1_i115 = 0; c1_i115 < 32; c1_i115++) {
    c1_b_B[c1_i115] = c1_B[c1_i115];
  }

  c1_b_xgemm(chartInstance, c1_b_k, c1_b_A, c1_b_B, c1_b_C);
}

static void c1_f_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void c1_g_scalarEg(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *c1_h_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(int32_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static int32_T c1_h_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  int32_T c1_y;
  int32_T c1_i116;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_i116, 1, 6, 0U, 0, 0U, 0);
  c1_y = c1_i116;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_g_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_sfEvent;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  int32_T c1_y;
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)chartInstanceVoid;
  c1_b_sfEvent = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_h_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_sfEvent),
    &c1_thisId);
  sf_mex_destroy(&c1_b_sfEvent);
  *(int32_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static uint8_T c1_i_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_b_is_active_c1_trackingSim, const char_T
  *c1_identifier)
{
  uint8_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_thisId.bParentIsCell = false;
  c1_y = c1_j_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c1_b_is_active_c1_trackingSim), &c1_thisId);
  sf_mex_destroy(&c1_b_is_active_c1_trackingSim);
  return c1_y;
}

static uint8_T c1_j_emlrt_marshallIn(SFc1_trackingSimInstanceStruct
  *chartInstance, const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  uint8_T c1_y;
  uint8_T c1_u0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_u0, 1, 3, 0U, 0, 0U, 0);
  c1_y = c1_u0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_b_cos(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     *c1_b_x)
{
  (void)chartInstance;
  *c1_b_x = muDoubleScalarCos(*c1_b_x);
}

static void c1_b_sin(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                     *c1_b_x)
{
  (void)chartInstance;
  *c1_b_x = muDoubleScalarSin(*c1_b_x);
}

static void c1_e_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[32], int32_T c1_iy0)
{
  int32_T c1_b_n;
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_d_a;
  int32_T c1_ix;
  int32_T c1_e_a;
  int32_T c1_iy;
  int32_T c1_f_a;
  int32_T c1_i117;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_g_a;
  int32_T c1_c;
  int32_T c1_h_a;
  int32_T c1_b_c;
  int32_T c1_i_a;
  int32_T c1_c_c;
  int32_T c1_j_a;
  int32_T c1_k_a;
  c1_b_n = c1_n;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  if (c1_b_n < 1) {
  } else if (c1_c_a == 0.0) {
  } else {
    c1_d_a = c1_b_ix0 - 1;
    c1_ix = c1_d_a;
    c1_e_a = c1_b_iy0 - 1;
    c1_iy = c1_e_a;
    c1_f_a = c1_b_n - 1;
    c1_i117 = c1_f_a;
    c1_b = c1_i117;
    c1_b_b = c1_b;
    c1_overflow = ((!(0 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 0; c1_b_k <= c1_i117; c1_b_k++) {
      c1_g_a = c1_iy;
      c1_c = c1_g_a;
      c1_h_a = c1_iy;
      c1_b_c = c1_h_a;
      c1_i_a = c1_ix;
      c1_c_c = c1_i_a;
      c1_y[c1_c] = c1_y[c1_b_c] + c1_c_a * c1_y[c1_c_c];
      c1_j_a = c1_ix + 1;
      c1_ix = c1_j_a;
      c1_k_a = c1_iy + 1;
      c1_iy = c1_k_a;
    }
  }
}

static void c1_f_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[32], int32_T c1_ix0, real_T c1_y[8],
  int32_T c1_iy0)
{
  int32_T c1_b_n;
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_d_a;
  int32_T c1_ix;
  int32_T c1_e_a;
  int32_T c1_iy;
  int32_T c1_f_a;
  int32_T c1_i118;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_g_a;
  int32_T c1_c;
  int32_T c1_h_a;
  int32_T c1_b_c;
  int32_T c1_i_a;
  int32_T c1_c_c;
  int32_T c1_j_a;
  int32_T c1_k_a;
  c1_b_n = c1_n;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  if (c1_b_n < 1) {
  } else if (c1_c_a == 0.0) {
  } else {
    c1_d_a = c1_b_ix0 - 1;
    c1_ix = c1_d_a;
    c1_e_a = c1_b_iy0 - 1;
    c1_iy = c1_e_a;
    c1_f_a = c1_b_n - 1;
    c1_i118 = c1_f_a;
    c1_b = c1_i118;
    c1_b_b = c1_b;
    c1_overflow = ((!(0 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 0; c1_b_k <= c1_i118; c1_b_k++) {
      c1_g_a = c1_iy;
      c1_c = c1_g_a;
      c1_h_a = c1_iy;
      c1_b_c = c1_h_a;
      c1_i_a = c1_ix;
      c1_c_c = c1_i_a;
      c1_y[c1_c] = c1_y[c1_b_c] + c1_c_a * c1_b_x[c1_c_c];
      c1_j_a = c1_ix + 1;
      c1_ix = c1_j_a;
      c1_k_a = c1_iy + 1;
      c1_iy = c1_k_a;
    }
  }
}

static void c1_g_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, real_T c1_b_x[8], int32_T c1_ix0, real_T c1_y[32],
  int32_T c1_iy0)
{
  int32_T c1_b_n;
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_d_a;
  int32_T c1_ix;
  int32_T c1_e_a;
  int32_T c1_iy;
  int32_T c1_f_a;
  int32_T c1_i119;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_g_a;
  int32_T c1_c;
  int32_T c1_h_a;
  int32_T c1_b_c;
  int32_T c1_i_a;
  int32_T c1_c_c;
  int32_T c1_j_a;
  int32_T c1_k_a;
  c1_b_n = c1_n;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  if (c1_b_n < 1) {
  } else if (c1_c_a == 0.0) {
  } else {
    c1_d_a = c1_b_ix0 - 1;
    c1_ix = c1_d_a;
    c1_e_a = c1_b_iy0 - 1;
    c1_iy = c1_e_a;
    c1_f_a = c1_b_n - 1;
    c1_i119 = c1_f_a;
    c1_b = c1_i119;
    c1_b_b = c1_b;
    c1_overflow = ((!(0 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 0; c1_b_k <= c1_i119; c1_b_k++) {
      c1_g_a = c1_iy;
      c1_c = c1_g_a;
      c1_h_a = c1_iy;
      c1_b_c = c1_h_a;
      c1_i_a = c1_ix;
      c1_c_c = c1_i_a;
      c1_y[c1_c] = c1_y[c1_b_c] + c1_c_a * c1_b_x[c1_c_c];
      c1_j_a = c1_ix + 1;
      c1_ix = c1_j_a;
      c1_k_a = c1_iy + 1;
      c1_iy = c1_k_a;
    }
  }
}

static void c1_b_xrotg(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  *c1_b_a, real_T *c1_b, real_T *c1_c, real_T *c1_b_s)
{
  real_T c1_c_a;
  real_T c1_b_b;
  real_T c1_c_b;
  real_T c1_d_a;
  real_T c1_b_c;
  real_T c1_c_s;
  (void)chartInstance;
  c1_c_a = *c1_b_a;
  c1_b_b = *c1_b;
  c1_c_b = c1_b_b;
  c1_d_a = c1_c_a;
  c1_b_c = 0.0;
  c1_c_s = 0.0;
  drotg(&c1_d_a, &c1_c_b, &c1_b_c, &c1_c_s);
  *c1_b_a = c1_d_a;
  *c1_b = c1_c_b;
  *c1_c = c1_b_c;
  *c1_b_s = c1_c_s;
}

static void c1_b_sqrt(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      *c1_b_x)
{
  real_T c1_c_x;
  boolean_T c1_b2;
  boolean_T c1_p;
  c1_c_x = *c1_b_x;
  c1_b2 = (c1_c_x < 0.0);
  c1_p = c1_b2;
  if (c1_p) {
    c1_c_error(chartInstance);
  }

  *c1_b_x = muDoubleScalarSqrt(*c1_b_x);
}

static void c1_h_xaxpy(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_n, real_T c1_b_a, int32_T c1_ix0, real_T c1_y[16], int32_T c1_iy0)
{
  int32_T c1_b_n;
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_d_a;
  int32_T c1_ix;
  int32_T c1_e_a;
  int32_T c1_iy;
  int32_T c1_f_a;
  int32_T c1_i120;
  int32_T c1_b;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_g_a;
  int32_T c1_c;
  int32_T c1_h_a;
  int32_T c1_b_c;
  int32_T c1_i_a;
  int32_T c1_c_c;
  int32_T c1_j_a;
  int32_T c1_k_a;
  c1_b_n = c1_n;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  if (c1_b_n < 1) {
  } else if (c1_c_a == 0.0) {
  } else {
    c1_d_a = c1_b_ix0 - 1;
    c1_ix = c1_d_a;
    c1_e_a = c1_b_iy0 - 1;
    c1_iy = c1_e_a;
    c1_f_a = c1_b_n - 1;
    c1_i120 = c1_f_a;
    c1_b = c1_i120;
    c1_b_b = c1_b;
    c1_overflow = ((!(0 > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_b_k = 0; c1_b_k <= c1_i120; c1_b_k++) {
      c1_g_a = c1_iy;
      c1_c = c1_g_a;
      c1_h_a = c1_iy;
      c1_b_c = c1_h_a;
      c1_i_a = c1_ix;
      c1_c_c = c1_i_a;
      c1_y[c1_c] = c1_y[c1_b_c] + c1_c_a * c1_y[c1_c_c];
      c1_j_a = c1_ix + 1;
      c1_ix = c1_j_a;
      c1_k_a = c1_iy + 1;
      c1_iy = c1_k_a;
    }
  }
}

static void c1_c_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[32], int32_T c1_ix0)
{
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_c_ix0;
  int32_T c1_d_a;
  int32_T c1_i121;
  int32_T c1_e_a;
  int32_T c1_b;
  int32_T c1_f_a;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_c_k;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_c_ix0 = c1_b_ix0;
  c1_d_a = c1_b_ix0 + 7;
  c1_i121 = c1_d_a;
  c1_e_a = c1_c_ix0;
  c1_b = c1_i121;
  c1_f_a = c1_e_a;
  c1_b_b = c1_b;
  c1_overflow = ((!(c1_f_a > c1_b_b)) && (c1_b_b > 2147483646));
  if (c1_overflow) {
    c1_check_forloop_overflow_error(chartInstance, c1_overflow);
  }

  for (c1_b_k = c1_c_ix0; c1_b_k <= c1_i121; c1_b_k++) {
    c1_c_k = c1_b_k - 1;
    c1_b_x[c1_c_k] *= c1_c_a;
  }
}

static void c1_d_xscal(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_a, real_T c1_b_x[16], int32_T c1_ix0)
{
  real_T c1_c_a;
  int32_T c1_b_ix0;
  int32_T c1_c_ix0;
  int32_T c1_d_a;
  int32_T c1_i122;
  int32_T c1_e_a;
  int32_T c1_b;
  int32_T c1_f_a;
  int32_T c1_b_b;
  boolean_T c1_overflow;
  int32_T c1_b_k;
  int32_T c1_c_k;
  c1_c_a = c1_b_a;
  c1_b_ix0 = c1_ix0;
  c1_c_ix0 = c1_b_ix0;
  c1_d_a = c1_b_ix0 + 3;
  c1_i122 = c1_d_a;
  c1_e_a = c1_c_ix0;
  c1_b = c1_i122;
  c1_f_a = c1_e_a;
  c1_b_b = c1_b;
  c1_overflow = ((!(c1_f_a > c1_b_b)) && (c1_b_b > 2147483646));
  if (c1_overflow) {
    c1_check_forloop_overflow_error(chartInstance, c1_overflow);
  }

  for (c1_b_k = c1_c_ix0; c1_b_k <= c1_i122; c1_b_k++) {
    c1_c_k = c1_b_k - 1;
    c1_b_x[c1_c_k] *= c1_c_a;
  }
}

static void c1_c_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s)
{
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  real_T c1_b_c;
  real_T c1_c_s;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_b_k;
  real_T c1_temp;
  int32_T c1_b_a;
  int32_T c1_c_a;
  (void)chartInstance;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_b_c = c1_c;
  c1_c_s = c1_b_s;
  c1_ix = c1_b_ix0 - 1;
  c1_iy = c1_b_iy0 - 1;
  for (c1_b_k = 1; c1_b_k < 5; c1_b_k++) {
    c1_temp = c1_b_c * c1_b_x[c1_ix] + c1_c_s * c1_b_x[c1_iy];
    c1_b_x[c1_iy] = c1_b_c * c1_b_x[c1_iy] - c1_c_s * c1_b_x[c1_ix];
    c1_b_x[c1_ix] = c1_temp;
    c1_b_a = c1_iy + 1;
    c1_iy = c1_b_a;
    c1_c_a = c1_ix + 1;
    c1_ix = c1_c_a;
  }
}

static void c1_d_xrot(SFc1_trackingSimInstanceStruct *chartInstance, real_T
                      c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0, real_T c1_c,
                      real_T c1_b_s)
{
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  real_T c1_b_c;
  real_T c1_c_s;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_b_k;
  real_T c1_temp;
  int32_T c1_b_a;
  int32_T c1_c_a;
  (void)chartInstance;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_b_c = c1_c;
  c1_c_s = c1_b_s;
  c1_ix = c1_b_ix0 - 1;
  c1_iy = c1_b_iy0 - 1;
  for (c1_b_k = 1; c1_b_k < 9; c1_b_k++) {
    c1_temp = c1_b_c * c1_b_x[c1_ix] + c1_c_s * c1_b_x[c1_iy];
    c1_b_x[c1_iy] = c1_b_c * c1_b_x[c1_iy] - c1_c_s * c1_b_x[c1_ix];
    c1_b_x[c1_ix] = c1_temp;
    c1_b_a = c1_iy + 1;
    c1_iy = c1_b_a;
    c1_c_a = c1_ix + 1;
    c1_ix = c1_c_a;
  }
}

static void c1_c_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[16], int32_T c1_ix0, int32_T c1_iy0)
{
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_b_k;
  real_T c1_temp;
  int32_T c1_b_a;
  int32_T c1_c_a;
  (void)chartInstance;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_ix = c1_b_ix0 - 1;
  c1_iy = c1_b_iy0 - 1;
  for (c1_b_k = 1; c1_b_k < 5; c1_b_k++) {
    c1_temp = c1_b_x[c1_ix];
    c1_b_x[c1_ix] = c1_b_x[c1_iy];
    c1_b_x[c1_iy] = c1_temp;
    c1_b_a = c1_ix + 1;
    c1_ix = c1_b_a;
    c1_c_a = c1_iy + 1;
    c1_iy = c1_c_a;
  }
}

static void c1_d_xswap(SFc1_trackingSimInstanceStruct *chartInstance, real_T
  c1_b_x[32], int32_T c1_ix0, int32_T c1_iy0)
{
  int32_T c1_b_ix0;
  int32_T c1_b_iy0;
  int32_T c1_ix;
  int32_T c1_iy;
  int32_T c1_b_k;
  real_T c1_temp;
  int32_T c1_b_a;
  int32_T c1_c_a;
  (void)chartInstance;
  c1_b_ix0 = c1_ix0;
  c1_b_iy0 = c1_iy0;
  c1_ix = c1_b_ix0 - 1;
  c1_iy = c1_b_iy0 - 1;
  for (c1_b_k = 1; c1_b_k < 9; c1_b_k++) {
    c1_temp = c1_b_x[c1_ix];
    c1_b_x[c1_ix] = c1_b_x[c1_iy];
    c1_b_x[c1_iy] = c1_temp;
    c1_b_a = c1_ix + 1;
    c1_ix = c1_b_a;
    c1_c_a = c1_iy + 1;
    c1_iy = c1_c_a;
  }
}

static void c1_b_xgemm(SFc1_trackingSimInstanceStruct *chartInstance, int32_T
  c1_b_k, real_T c1_A[16], real_T c1_B[32], real_T c1_C[32])
{
  int32_T c1_c_k;
  int32_T c1_b_a;
  int32_T c1_km1;
  int32_T c1_cr;
  int32_T c1_br;
  int32_T c1_b_cr;
  int32_T c1_c_cr;
  int32_T c1_c_a;
  int32_T c1_i123;
  int32_T c1_d_a;
  int32_T c1_i124;
  int32_T c1_ar;
  int32_T c1_e_a;
  int32_T c1_f_a;
  int32_T c1_b;
  int32_T c1_g_a;
  int32_T c1_b_br;
  int32_T c1_b_b;
  int32_T c1_c_b;
  boolean_T c1_overflow;
  int32_T c1_c;
  int32_T c1_h_a;
  int32_T c1_d_b;
  int32_T c1_ic;
  int32_T c1_i125;
  int32_T c1_i_a;
  int32_T c1_e_b;
  int32_T c1_b_ic;
  int32_T c1_j_a;
  int32_T c1_f_b;
  boolean_T c1_b_overflow;
  int32_T c1_ib;
  int32_T c1_b_ib;
  real_T c1_temp;
  int32_T c1_k_a;
  int32_T c1_ia;
  int32_T c1_l_a;
  int32_T c1_i126;
  int32_T c1_m_a;
  int32_T c1_i127;
  int32_T c1_n_a;
  int32_T c1_g_b;
  int32_T c1_o_a;
  int32_T c1_h_b;
  boolean_T c1_c_overflow;
  int32_T c1_c_ic;
  int32_T c1_p_a;
  c1_c_k = c1_b_k;
  c1_b_a = c1_c_k;
  c1_km1 = c1_b_a;
  for (c1_cr = 0; c1_cr < 29; c1_cr += 4) {
    c1_b_cr = c1_cr;
    c1_c_a = c1_b_cr + 1;
    c1_i123 = c1_c_a;
    c1_d_a = c1_b_cr + 4;
    c1_i124 = c1_d_a;
    c1_e_a = c1_i123;
    c1_b = c1_i124;
    c1_g_a = c1_e_a;
    c1_b_b = c1_b;
    c1_overflow = ((!(c1_g_a > c1_b_b)) && (c1_b_b > 2147483646));
    if (c1_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_overflow);
    }

    for (c1_ic = c1_i123; c1_ic <= c1_i124; c1_ic++) {
      c1_b_ic = c1_ic - 1;
      c1_C[c1_b_ic] = 0.0;
    }
  }

  c1_br = 0;
  for (c1_c_cr = 0; c1_c_cr < 29; c1_c_cr += 4) {
    c1_b_cr = c1_c_cr;
    c1_ar = 0;
    c1_f_a = c1_br + 1;
    c1_br = c1_f_a;
    c1_b_br = c1_br;
    c1_c_b = c1_km1 - 1;
    c1_c = c1_c_b << 3;
    c1_h_a = c1_br;
    c1_d_b = c1_c;
    c1_i125 = c1_h_a + c1_d_b;
    c1_i_a = c1_b_br;
    c1_e_b = c1_i125;
    c1_j_a = c1_i_a;
    c1_f_b = c1_e_b;
    c1_b_overflow = ((!(c1_j_a > c1_f_b)) && (c1_f_b > 2147483639));
    if (c1_b_overflow) {
      c1_check_forloop_overflow_error(chartInstance, c1_b_overflow);
    }

    for (c1_ib = c1_b_br; c1_ib <= c1_i125; c1_ib += 8) {
      c1_b_ib = c1_ib - 1;
      if (c1_B[c1_b_ib] != 0.0) {
        c1_temp = c1_B[c1_b_ib];
        c1_ia = c1_ar - 1;
        c1_l_a = c1_b_cr + 1;
        c1_i126 = c1_l_a;
        c1_m_a = c1_b_cr + 4;
        c1_i127 = c1_m_a;
        c1_n_a = c1_i126;
        c1_g_b = c1_i127;
        c1_o_a = c1_n_a;
        c1_h_b = c1_g_b;
        c1_c_overflow = ((!(c1_o_a > c1_h_b)) && (c1_h_b > 2147483646));
        if (c1_c_overflow) {
          c1_check_forloop_overflow_error(chartInstance, c1_c_overflow);
        }

        for (c1_c_ic = c1_i126; c1_c_ic <= c1_i127; c1_c_ic++) {
          c1_b_ic = c1_c_ic - 1;
          c1_p_a = c1_ia + 1;
          c1_ia = c1_p_a;
          c1_C[c1_b_ic] += c1_temp * c1_A[c1_ia];
        }
      }

      c1_k_a = c1_ar + 4;
      c1_ar = c1_k_a;
    }
  }
}

static void init_dsm_address_info(SFc1_trackingSimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_simulink_io_address(SFc1_trackingSimInstanceStruct
  *chartInstance)
{
  chartInstance->c1_dots = (real_T (*)[8])ssGetInputPortSignal_wrapper
    (chartInstance->S, 0);
  chartInstance->c1_m0 = (real_T (*)[3])ssGetInputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c1_hat_s = (real_T (*)[4])ssGetOutputPortSignal_wrapper
    (chartInstance->S, 1);
  chartInstance->c1_m1 = (real_T (*)[3])ssGetInputPortSignal_wrapper
    (chartInstance->S, 2);
  chartInstance->c1_s = (real_T (*)[4])ssGetInputPortSignal_wrapper
    (chartInstance->S, 3);
  chartInstance->c1_t = (real_T *)ssGetInputPortSignal_wrapper(chartInstance->S,
    4);
  chartInstance->c1_x = (real_T (*)[12])ssGetInputPortSignal_wrapper
    (chartInstance->S, 5);
  chartInstance->c1_k = (real_T (*)[12])ssGetInputPortSignal_wrapper
    (chartInstance->S, 6);
  chartInstance->c1_a = (real_T *)ssGetInputPortSignal_wrapper(chartInstance->S,
    7);
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c1_trackingSim_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(149883294U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(1908065590U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(4004975201U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3010810331U);
}

mxArray* sf_c1_trackingSim_get_post_codegen_info(void);
mxArray *sf_c1_trackingSim_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals", "postCodegenInfo" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1, 1, sizeof
    (autoinheritanceFields)/sizeof(autoinheritanceFields[0]),
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("bLK5Co0BuOWwnH7PxvVvxC");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,8,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(8);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,0,mxREAL);
      double *pr = mxGetPr(mxSize);
      mxSetField(mxData,4,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,4,"type",mxType);
    }

    mxSetField(mxData,4,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(12);
      mxSetField(mxData,5,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,5,"type",mxType);
    }

    mxSetField(mxData,5,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      pr[1] = (double)(4);
      mxSetField(mxData,6,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,6,"type",mxType);
    }

    mxSetField(mxData,6,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,0,mxREAL);
      double *pr = mxGetPr(mxSize);
      mxSetField(mxData,7,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,7,"type",mxType);
    }

    mxSetField(mxData,7,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,1,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt", "isFixedPointType" };

      mxArray *mxType = mxCreateStructMatrix(1,1,sizeof(typeFields)/sizeof
        (typeFields[0]),typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxType,0,"isFixedPointType",mxCreateDoubleScalar(0));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  {
    mxArray* mxPostCodegenInfo = sf_c1_trackingSim_get_post_codegen_info();
    mxSetField(mxAutoinheritanceInfo,0,"postCodegenInfo",mxPostCodegenInfo);
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c1_trackingSim_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,1);
  mxSetCell(mxcell3p, 0, mxCreateString("coder.internal.blas.BLASApi"));
  return(mxcell3p);
}

mxArray *sf_c1_trackingSim_jit_fallback_info(void)
{
  const char *infoFields[] = { "fallbackType", "fallbackReason",
    "hiddenFallbackType", "hiddenFallbackReason", "incompatibleSymbol" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 5, infoFields);
  mxArray *fallbackType = mxCreateString("pre");
  mxArray *fallbackReason = mxCreateString("hasBreakpoints");
  mxArray *hiddenFallbackType = mxCreateString("none");
  mxArray *hiddenFallbackReason = mxCreateString("");
  mxArray *incompatibleSymbol = mxCreateString("");
  mxSetField(mxInfo, 0, infoFields[0], fallbackType);
  mxSetField(mxInfo, 0, infoFields[1], fallbackReason);
  mxSetField(mxInfo, 0, infoFields[2], hiddenFallbackType);
  mxSetField(mxInfo, 0, infoFields[3], hiddenFallbackReason);
  mxSetField(mxInfo, 0, infoFields[4], incompatibleSymbol);
  return mxInfo;
}

mxArray *sf_c1_trackingSim_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

mxArray* sf_c1_trackingSim_get_post_codegen_info(void)
{
  const char* fieldNames[] = { "exportedFunctionsUsedByThisChart",
    "exportedFunctionsChecksum" };

  mwSize dims[2] = { 1, 1 };

  mxArray* mxPostCodegenInfo = mxCreateStructArray(2, dims, sizeof(fieldNames)/
    sizeof(fieldNames[0]), fieldNames);

  {
    mxArray* mxExportedFunctionsChecksum = mxCreateString("");
    mwSize exp_dims[2] = { 0, 1 };

    mxArray* mxExportedFunctionsUsedByThisChart = mxCreateCellArray(2, exp_dims);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsUsedByThisChart",
               mxExportedFunctionsUsedByThisChart);
    mxSetField(mxPostCodegenInfo, 0, "exportedFunctionsChecksum",
               mxExportedFunctionsChecksum);
  }

  return mxPostCodegenInfo;
}

static const mxArray *sf_get_sim_state_info_c1_trackingSim(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[5],T\"hat_s\",},{M[8],M[0],T\"is_active_c1_trackingSim\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c1_trackingSim_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_trackingSimInstanceStruct *chartInstance =
      (SFc1_trackingSimInstanceStruct *)sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _trackingSimMachineNumber_,
           1,
           1,
           1,
           0,
           9,
           0,
           0,
           0,
           0,
           1,
           &chartInstance->chartNumber,
           &chartInstance->instanceNumber,
           (void *)S);

        /* Each instance must initialize its own list of scripts */
        init_script_number_translation(_trackingSimMachineNumber_,
          chartInstance->chartNumber,chartInstance->instanceNumber);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_trackingSimMachineNumber_,
             chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _trackingSimMachineNumber_,
            chartInstance->chartNumber,
            0,
            0,
            0);
          _SFD_SET_DATA_PROPS(0,1,1,0,"dots");
          _SFD_SET_DATA_PROPS(1,1,1,0,"m0");
          _SFD_SET_DATA_PROPS(2,1,1,0,"m1");
          _SFD_SET_DATA_PROPS(3,1,1,0,"s");
          _SFD_SET_DATA_PROPS(4,1,1,0,"t");
          _SFD_SET_DATA_PROPS(5,1,1,0,"x");
          _SFD_SET_DATA_PROPS(6,1,1,0,"k");
          _SFD_SET_DATA_PROPS(7,1,1,0,"a");
          _SFD_SET_DATA_PROPS(8,2,0,1,"hat_s");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,0,0,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,119);
        _SFD_CV_INIT_SCRIPT(0,1,0,0,0,0,0,0,0,0,0);
        _SFD_CV_INIT_SCRIPT_FCN(0,0,"Jac1",0,-1,4508);

        {
          unsigned int dimVector[1];
          dimVector[0]= 8U;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_f_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3U;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_e_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3U;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_e_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4U;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(4,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_b_sf_marshallOut,(MexInFcnForType)NULL);

        {
          unsigned int dimVector[1];
          dimVector[0]= 12U;
          _SFD_SET_DATA_COMPILED_PROPS(5,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_d_sf_marshallOut,(MexInFcnForType)NULL);
        }

        {
          unsigned int dimVector[2];
          dimVector[0]= 3U;
          dimVector[1]= 4U;
          _SFD_SET_DATA_COMPILED_PROPS(6,SF_DOUBLE,2,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_c_sf_marshallOut,(MexInFcnForType)NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(7,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_b_sf_marshallOut,(MexInFcnForType)NULL);

        {
          unsigned int dimVector[1];
          dimVector[0]= 4U;
          _SFD_SET_DATA_COMPILED_PROPS(8,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)
            c1_sf_marshallIn);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _trackingSimMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static void chart_debug_initialize_data_addresses(SimStruct *S)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_trackingSimInstanceStruct *chartInstance =
      (SFc1_trackingSimInstanceStruct *)sf_get_chart_instance_ptr(S);
    if (ssIsFirstInitCond(S)) {
      /* do this only if simulation is starting and after we know the addresses of all data */
      {
        _SFD_SET_DATA_VALUE_PTR(0U, *chartInstance->c1_dots);
        _SFD_SET_DATA_VALUE_PTR(1U, *chartInstance->c1_m0);
        _SFD_SET_DATA_VALUE_PTR(8U, *chartInstance->c1_hat_s);
        _SFD_SET_DATA_VALUE_PTR(2U, *chartInstance->c1_m1);
        _SFD_SET_DATA_VALUE_PTR(3U, *chartInstance->c1_s);
        _SFD_SET_DATA_VALUE_PTR(4U, chartInstance->c1_t);
        _SFD_SET_DATA_VALUE_PTR(5U, *chartInstance->c1_x);
        _SFD_SET_DATA_VALUE_PTR(6U, *chartInstance->c1_k);
        _SFD_SET_DATA_VALUE_PTR(7U, chartInstance->c1_a);
      }
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "sEyokJVa9cxe5wtxFBo6hJG";
}

static void sf_opaque_initialize_c1_trackingSim(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc1_trackingSimInstanceStruct*) chartInstanceVar)
    ->S,0);
  initialize_params_c1_trackingSim((SFc1_trackingSimInstanceStruct*)
    chartInstanceVar);
  initialize_c1_trackingSim((SFc1_trackingSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c1_trackingSim(void *chartInstanceVar)
{
  enable_c1_trackingSim((SFc1_trackingSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c1_trackingSim(void *chartInstanceVar)
{
  disable_c1_trackingSim((SFc1_trackingSimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c1_trackingSim(void *chartInstanceVar)
{
  sf_gateway_c1_trackingSim((SFc1_trackingSimInstanceStruct*) chartInstanceVar);
}

static const mxArray* sf_opaque_get_sim_state_c1_trackingSim(SimStruct* S)
{
  return get_sim_state_c1_trackingSim((SFc1_trackingSimInstanceStruct *)
    sf_get_chart_instance_ptr(S));     /* raw sim ctx */
}

static void sf_opaque_set_sim_state_c1_trackingSim(SimStruct* S, const mxArray
  *st)
{
  set_sim_state_c1_trackingSim((SFc1_trackingSimInstanceStruct*)
    sf_get_chart_instance_ptr(S), st);
}

static void sf_opaque_terminate_c1_trackingSim(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc1_trackingSimInstanceStruct*) chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_trackingSim_optimization_info();
    }

    finalize_c1_trackingSim((SFc1_trackingSimInstanceStruct*) chartInstanceVar);
    utFree(chartInstanceVar);
    if (ssGetUserData(S)!= NULL) {
      sf_free_ChartRunTimeInfo(S);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc1_trackingSim((SFc1_trackingSimInstanceStruct*)
    chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c1_trackingSim(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c1_trackingSim((SFc1_trackingSimInstanceStruct*)
      sf_get_chart_instance_ptr(S));
  }
}

static void mdlSetWorkWidths_c1_trackingSim(SimStruct *S)
{
  /* Set overwritable ports for inplace optimization */
  ssMdlUpdateIsEmpty(S, 1);
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_trackingSim_optimization_info(sim_mode_is_rtw_gen
      (S), sim_mode_is_modelref_sim(S), sim_mode_is_external(S));
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,1);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,1);
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,1,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_set_chart_accesses_machine_info(S, sf_get_instance_specialization(),
      infoStruct, 1);
    sf_update_buildInfo(S, sf_get_instance_specialization(),infoStruct,1);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 4, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 5, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 6, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 7, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,1,8);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,1,1);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=1; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 8; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,1);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(4211309911U));
  ssSetChecksum1(S,(3039251024U));
  ssSetChecksum2(S,(845116496U));
  ssSetChecksum3(S,(1996257849U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSetStateSemanticsClassicAndSynchronous(S, true);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c1_trackingSim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c1_trackingSim(SimStruct *S)
{
  SFc1_trackingSimInstanceStruct *chartInstance;
  chartInstance = (SFc1_trackingSimInstanceStruct *)utMalloc(sizeof
    (SFc1_trackingSimInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  memset(chartInstance, 0, sizeof(SFc1_trackingSimInstanceStruct));
  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c1_trackingSim;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c1_trackingSim;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c1_trackingSim;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c1_trackingSim;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c1_trackingSim;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c1_trackingSim;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c1_trackingSim;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c1_trackingSim;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c1_trackingSim;
  chartInstance->chartInfo.mdlStart = mdlStart_c1_trackingSim;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c1_trackingSim;
  chartInstance->chartInfo.callGetHoverDataForMsg = NULL;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->chartInfo.callAtomicSubchartUserFcn = NULL;
  chartInstance->chartInfo.callAtomicSubchartAutoFcn = NULL;
  chartInstance->chartInfo.debugInstance = sfGlobalDebugInstanceStruct;
  chartInstance->S = S;
  sf_init_ChartRunTimeInfo(S, &(chartInstance->chartInfo), false, 0);
  init_dsm_address_info(chartInstance);
  init_simulink_io_address(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  chart_debug_initialization(S,1);
  mdl_start_c1_trackingSim(chartInstance);
}

void c1_trackingSim_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c1_trackingSim(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c1_trackingSim(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c1_trackingSim(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c1_trackingSim_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
