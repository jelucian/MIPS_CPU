/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Jesus Luciano/Desktop/ISE_Port/test/CPU_TEST_MODULE_04.v";
static int ng1[] = {9, 0};
static int ng2[] = {1, 0};
static const char *ng3 = " ps";
static const char *ng4 = "iM_04.mem";
static const char *ng5 = "dM_04.mem";
static int ng6[] = {0, 0};
static int ng7[] = {10000, 0};
static const char *ng8 = "ERROR: REACHED END OF TESTBENCH LOOP";



static void Always_46_0(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;

LAB0:    t1 = (t0 + 4448U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(46, ng0);
    t2 = (t0 + 4256);
    xsi_process_wait(t2, 5000LL);
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(46, ng0);
    t4 = (t0 + 3208);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memset(t3, 0, 8);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB8;

LAB6:    if (*((unsigned int *)t7) == 0)
        goto LAB5;

LAB7:    t13 = (t3 + 4);
    *((unsigned int *)t3) = 1;
    *((unsigned int *)t13) = 1;

LAB8:    t14 = (t3 + 4);
    t15 = (t6 + 4);
    t16 = *((unsigned int *)t6);
    t17 = (~(t16));
    *((unsigned int *)t3) = t17;
    *((unsigned int *)t14) = 0;
    if (*((unsigned int *)t15) != 0)
        goto LAB10;

LAB9:    t22 = *((unsigned int *)t3);
    *((unsigned int *)t3) = (t22 & 1U);
    t23 = *((unsigned int *)t14);
    *((unsigned int *)t14) = (t23 & 1U);
    t24 = (t0 + 3208);
    xsi_vlogvar_assign_value(t24, t3, 0, 0, 1);
    goto LAB2;

LAB5:    *((unsigned int *)t3) = 1;
    goto LAB8;

LAB10:    t18 = *((unsigned int *)t3);
    t19 = *((unsigned int *)t15);
    *((unsigned int *)t3) = (t18 | t19);
    t20 = *((unsigned int *)t14);
    t21 = *((unsigned int *)t15);
    *((unsigned int *)t14) = (t20 | t21);
    goto LAB9;

}

static void Initial_48_1(char *t0)
{
    char t3[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    int t22;
    char *t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;

LAB0:    t1 = (t0 + 4696U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(49, ng0);

LAB4:    xsi_set_current_line(51, ng0);
    t2 = ((char*)((ng1)));
    memset(t3, 0, 8);
    xsi_vlog_signed_unary_minus(t3, 32, t2, 32);
    t4 = ((char*)((ng2)));
    t5 = ((char*)((ng1)));
    xsi_vlog_setTimeFormat(*((unsigned int *)t3), *((unsigned int *)t4), ng3, 0, *((unsigned int *)t5));
    xsi_set_current_line(54, ng0);
    t2 = (t0 + 7104);
    t4 = *((char **)t2);
    xsi_vlogfile_readmemh(ng4, 0, ((char*)(t4)), 0, 0, 0, 0);
    xsi_set_current_line(56, ng0);
    t2 = (t0 + 7144);
    t4 = *((char **)t2);
    xsi_vlogfile_readmemh(ng5, 0, ((char*)(t4)), 0, 0, 0, 0);
    xsi_set_current_line(57, ng0);
    t2 = ((char*)((ng6)));
    t4 = (t0 + 3208);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 1);
    xsi_set_current_line(58, ng0);
    t2 = ((char*)((ng6)));
    t4 = (t0 + 3368);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 1);
    xsi_set_current_line(59, ng0);
    t2 = (t0 + 5016);
    *((int *)t2) = 1;
    t4 = (t0 + 4728);
    *((char **)t4) = t2;
    *((char **)t1) = &&LAB5;

LAB1:    return;
LAB5:    xsi_set_current_line(60, ng0);
    t5 = ((char*)((ng2)));
    t6 = (t0 + 3368);
    xsi_vlogvar_assign_value(t6, t5, 0, 0, 1);
    xsi_set_current_line(61, ng0);
    t2 = (t0 + 5032);
    *((int *)t2) = 1;
    t4 = (t0 + 4728);
    *((char **)t4) = t2;
    *((char **)t1) = &&LAB6;
    goto LAB1;

LAB6:    xsi_set_current_line(62, ng0);
    t5 = ((char*)((ng6)));
    t6 = (t0 + 3368);
    xsi_vlogvar_assign_value(t6, t5, 0, 0, 1);
    xsi_set_current_line(64, ng0);
    xsi_set_current_line(64, ng0);
    t2 = ((char*)((ng6)));
    t4 = (t0 + 3528);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 32);

LAB7:    t2 = (t0 + 3528);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    t6 = ((char*)((ng7)));
    memset(t3, 0, 8);
    xsi_vlog_signed_less(t3, 32, t5, 32, t6, 32);
    t7 = (t3 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t3);
    t11 = (t10 & t9);
    t12 = (t11 != 0);
    if (t12 > 0)
        goto LAB8;

LAB9:    xsi_set_current_line(67, ng0);
    xsi_vlogfile_write(1, 0, 0, ng8, 1, t0);
    xsi_set_current_line(69, ng0);
    t2 = (t0 + 4504);
    t4 = (t0 + 7184);
    t5 = *((char **)t4);
    t6 = (t0 + 7192);
    t7 = xsi_create_subprogram_invocation(t2, 0, *((char **)t6), ((char*)(t5)), 0, 0);
    xsi_vlog_subprogram_pushinvocation(((char*)(t5)), t7);

LAB13:    t13 = (t0 + 4600);
    t14 = *((char **)t13);
    t15 = (t14 + 80U);
    t16 = *((char **)t15);
    t17 = (t16 + 272U);
    t18 = *((char **)t17);
    t19 = (t18 + 0U);
    t20 = *((char **)t19);
    t21 = (t0 + 7192);
    t22 = ((int  (*)(char *, char *))t20)(*((char **)t21), t14);

LAB15:    if (t22 != 0)
        goto LAB16;

LAB11:    t14 = (t0 + 7232);
    t23 = *((char **)t14);
    xsi_vlog_subprogram_popinvocation(((char*)(t23)));

LAB12:    t24 = (t0 + 4600);
    t25 = *((char **)t24);
    t24 = (t0 + 7232);
    t26 = *((char **)t24);
    t27 = (t0 + 4504);
    t28 = 0;
    xsi_delete_subprogram_invocation(((char*)(t26)), t25, t0, t27, t28);
    xsi_set_current_line(70, ng0);
    t2 = (t0 + 4504);
    t4 = (t0 + 7280);
    t5 = *((char **)t4);
    t6 = (t0 + 7288);
    t7 = xsi_create_subprogram_invocation(t2, 0, *((char **)t6), ((char*)(t5)), 0, 0);
    xsi_vlog_subprogram_pushinvocation(((char*)(t5)), t7);

LAB19:    t13 = (t0 + 4600);
    t14 = *((char **)t13);
    t15 = (t14 + 80U);
    t16 = *((char **)t15);
    t17 = (t16 + 272U);
    t18 = *((char **)t17);
    t19 = (t18 + 0U);
    t20 = *((char **)t19);
    t21 = (t0 + 7288);
    t22 = ((int  (*)(char *, char *))t20)(*((char **)t21), t14);

LAB21:    if (t22 != 0)
        goto LAB22;

LAB17:    t14 = (t0 + 7328);
    t23 = *((char **)t14);
    xsi_vlog_subprogram_popinvocation(((char*)(t23)));

LAB18:    t24 = (t0 + 4600);
    t25 = *((char **)t24);
    t24 = (t0 + 7328);
    t26 = *((char **)t24);
    t27 = (t0 + 4504);
    t28 = 0;
    xsi_delete_subprogram_invocation(((char*)(t26)), t25, t0, t27, t28);
    goto LAB1;

LAB8:    xsi_set_current_line(65, ng0);
    t13 = (t0 + 5048);
    *((int *)t13) = 1;
    t14 = (t0 + 4728);
    *((char **)t14) = t13;
    *((char **)t1) = &&LAB10;
    goto LAB1;

LAB10:    xsi_set_current_line(64, ng0);
    t2 = (t0 + 3528);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    t6 = ((char*)((ng2)));
    memset(t3, 0, 8);
    xsi_vlog_signed_add(t3, 32, t5, 32, t6, 32);
    t7 = (t0 + 3528);
    xsi_vlogvar_assign_value(t7, t3, 0, 0, 32);
    goto LAB7;

LAB14:;
LAB16:    t13 = (t0 + 4696U);
    *((char **)t13) = &&LAB13;
    goto LAB1;

LAB20:;
LAB22:    t13 = (t0 + 4696U);
    *((char **)t13) = &&LAB19;
    goto LAB1;

}


extern void work_m_00000000003361093906_2539553759_init()
{
	static char *pe[] = {(void *)Always_46_0,(void *)Initial_48_1};
	xsi_register_didat("work_m_00000000003361093906_2539553759", "isim/CPU_TEST_MODULE_04_isim_beh.exe.sim/work/m_00000000003361093906_2539553759.didat");
	xsi_register_executes(pe);
}
