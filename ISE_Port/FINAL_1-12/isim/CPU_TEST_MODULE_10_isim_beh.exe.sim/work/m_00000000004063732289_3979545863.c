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
static const char *ng0 = "C:/Users/Jesus Luciano/Desktop/ISE_Port/test/regfile32.v";
static unsigned int ng1[] = {0U, 0U};
static int ng2[] = {0, 0};
static unsigned int ng3[] = {1U, 0U};



static void Cont_29_0(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;

LAB0:    t1 = (t0 + 3648U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(29, ng0);
    t2 = (t0 + 2728);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = (t0 + 2728);
    t7 = (t6 + 72U);
    t8 = *((char **)t7);
    t9 = (t0 + 2728);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t12 = (t0 + 1528U);
    t13 = *((char **)t12);
    xsi_vlog_generic_get_array_select_value(t5, 32, t4, t8, t11, 2, 1, t13, 5, 2);
    t12 = (t0 + 4576);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t5, 8);
    xsi_driver_vfirst_trans(t12, 0, 31);
    t18 = (t0 + 4464);
    *((int *)t18) = 1;

LAB1:    return;
}

static void Cont_30_1(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;

LAB0:    t1 = (t0 + 3896U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(30, ng0);
    t2 = (t0 + 2728);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t6 = (t0 + 2728);
    t7 = (t6 + 72U);
    t8 = *((char **)t7);
    t9 = (t0 + 2728);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t12 = (t0 + 1688U);
    t13 = *((char **)t12);
    xsi_vlog_generic_get_array_select_value(t5, 32, t4, t8, t11, 2, 1, t13, 5, 2);
    t12 = (t0 + 4640);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t5, 8);
    xsi_driver_vfirst_trans(t12, 0, 31);
    t18 = (t0 + 4480);
    *((int *)t18) = 1;

LAB1:    return;
}

static void Always_33_2(char *t0)
{
    char t13[8];
    char t14[8];
    char t44[8];
    char t45[8];
    char t51[8];
    char t89[8];
    char t90[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    char *t21;
    char *t22;
    unsigned int t23;
    int t24;
    char *t25;
    unsigned int t26;
    int t27;
    int t28;
    unsigned int t29;
    unsigned int t30;
    int t31;
    int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t52;
    unsigned int t53;
    unsigned int t54;
    char *t55;
    char *t56;
    char *t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    char *t65;
    char *t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    unsigned int t70;
    unsigned int t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    unsigned int t76;
    unsigned int t77;
    unsigned int t78;
    unsigned int t79;
    unsigned int t80;
    char *t81;
    unsigned int t82;
    unsigned int t83;
    unsigned int t84;
    unsigned int t85;
    unsigned int t86;
    char *t87;
    char *t88;
    char *t91;
    char *t92;
    char *t93;
    char *t94;
    char *t95;
    char *t96;
    char *t97;
    char *t98;
    unsigned int t99;
    char *t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    int t104;
    int t105;

LAB0:    t1 = (t0 + 4144U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(33, ng0);
    t2 = (t0 + 4496);
    *((int *)t2) = 1;
    t3 = (t0 + 4176);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(33, ng0);

LAB5:    xsi_set_current_line(34, ng0);
    t4 = (t0 + 1208U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(36, ng0);

LAB11:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 1368U);
    t3 = *((char **)t2);
    t2 = ((char*)((ng3)));
    memset(t13, 0, 8);
    t4 = (t3 + 4);
    t5 = (t2 + 4);
    t6 = *((unsigned int *)t3);
    t7 = *((unsigned int *)t2);
    t8 = (t6 ^ t7);
    t9 = *((unsigned int *)t4);
    t10 = *((unsigned int *)t5);
    t23 = (t9 ^ t10);
    t26 = (t8 | t23);
    t29 = *((unsigned int *)t4);
    t30 = *((unsigned int *)t5);
    t33 = (t29 | t30);
    t34 = (~(t33));
    t35 = (t26 & t34);
    if (t35 != 0)
        goto LAB15;

LAB12:    if (t33 != 0)
        goto LAB14;

LAB13:    *((unsigned int *)t13) = 1;

LAB15:    memset(t14, 0, 8);
    t12 = (t13 + 4);
    t36 = *((unsigned int *)t12);
    t37 = (~(t36));
    t38 = *((unsigned int *)t13);
    t39 = (t38 & t37);
    t40 = (t39 & 1U);
    if (t40 != 0)
        goto LAB16;

LAB17:    if (*((unsigned int *)t12) != 0)
        goto LAB18;

LAB19:    t16 = (t14 + 4);
    t41 = *((unsigned int *)t14);
    t42 = *((unsigned int *)t16);
    t43 = (t41 || t42);
    if (t43 > 0)
        goto LAB20;

LAB21:    memcpy(t51, t14, 8);

LAB22:    t81 = (t51 + 4);
    t82 = *((unsigned int *)t81);
    t83 = (~(t82));
    t84 = *((unsigned int *)t51);
    t85 = (t84 & t83);
    t86 = (t85 != 0);
    if (t86 > 0)
        goto LAB35;

LAB36:    xsi_set_current_line(41, ng0);
    t2 = (t0 + 2728);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 2728);
    t11 = (t5 + 72U);
    t12 = *((char **)t11);
    t15 = (t0 + 2728);
    t16 = (t15 + 64U);
    t17 = *((char **)t16);
    t18 = (t0 + 1848U);
    t19 = *((char **)t18);
    xsi_vlog_generic_get_array_select_value(t13, 32, t4, t12, t17, 2, 1, t19, 5, 2);
    t18 = (t0 + 2728);
    t20 = (t0 + 2728);
    t21 = (t20 + 72U);
    t22 = *((char **)t21);
    t25 = (t0 + 2728);
    t55 = (t25 + 64U);
    t56 = *((char **)t55);
    t57 = (t0 + 1848U);
    t65 = *((char **)t57);
    xsi_vlog_generic_convert_array_indices(t14, t44, t22, t56, 2, 1, t65, 5, 2);
    t57 = (t14 + 4);
    t6 = *((unsigned int *)t57);
    t24 = (!(t6));
    t66 = (t44 + 4);
    t7 = *((unsigned int *)t66);
    t27 = (!(t7));
    t28 = (t24 && t27);
    if (t28 == 1)
        goto LAB40;

LAB41:
LAB37:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(35, ng0);
    t11 = ((char*)((ng1)));
    t12 = (t0 + 2728);
    t15 = (t0 + 2728);
    t16 = (t15 + 72U);
    t17 = *((char **)t16);
    t18 = (t0 + 2728);
    t19 = (t18 + 64U);
    t20 = *((char **)t19);
    t21 = ((char*)((ng2)));
    xsi_vlog_generic_convert_array_indices(t13, t14, t17, t20, 2, 1, t21, 32, 1);
    t22 = (t13 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (!(t23));
    t25 = (t14 + 4);
    t26 = *((unsigned int *)t25);
    t27 = (!(t26));
    t28 = (t24 && t27);
    if (t28 == 1)
        goto LAB9;

LAB10:    goto LAB8;

LAB9:    t29 = *((unsigned int *)t13);
    t30 = *((unsigned int *)t14);
    t31 = (t29 - t30);
    t32 = (t31 + 1);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, *((unsigned int *)t14), t32, 0LL);
    goto LAB10;

LAB14:    t11 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t11) = 1;
    goto LAB15;

LAB16:    *((unsigned int *)t14) = 1;
    goto LAB19;

LAB18:    t15 = (t14 + 4);
    *((unsigned int *)t14) = 1;
    *((unsigned int *)t15) = 1;
    goto LAB19;

LAB20:    t17 = (t0 + 1848U);
    t18 = *((char **)t17);
    t17 = ((char*)((ng1)));
    memset(t44, 0, 8);
    t19 = (t18 + 4);
    if (*((unsigned int *)t19) != 0)
        goto LAB24;

LAB23:    t20 = (t17 + 4);
    if (*((unsigned int *)t20) != 0)
        goto LAB24;

LAB27:    if (*((unsigned int *)t18) > *((unsigned int *)t17))
        goto LAB25;

LAB26:    memset(t45, 0, 8);
    t22 = (t44 + 4);
    t46 = *((unsigned int *)t22);
    t47 = (~(t46));
    t48 = *((unsigned int *)t44);
    t49 = (t48 & t47);
    t50 = (t49 & 1U);
    if (t50 != 0)
        goto LAB28;

LAB29:    if (*((unsigned int *)t22) != 0)
        goto LAB30;

LAB31:    t52 = *((unsigned int *)t14);
    t53 = *((unsigned int *)t45);
    t54 = (t52 & t53);
    *((unsigned int *)t51) = t54;
    t55 = (t14 + 4);
    t56 = (t45 + 4);
    t57 = (t51 + 4);
    t58 = *((unsigned int *)t55);
    t59 = *((unsigned int *)t56);
    t60 = (t58 | t59);
    *((unsigned int *)t57) = t60;
    t61 = *((unsigned int *)t57);
    t62 = (t61 != 0);
    if (t62 == 1)
        goto LAB32;

LAB33:
LAB34:    goto LAB22;

LAB24:    t21 = (t44 + 4);
    *((unsigned int *)t44) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB26;

LAB25:    *((unsigned int *)t44) = 1;
    goto LAB26;

LAB28:    *((unsigned int *)t45) = 1;
    goto LAB31;

LAB30:    t25 = (t45 + 4);
    *((unsigned int *)t45) = 1;
    *((unsigned int *)t25) = 1;
    goto LAB31;

LAB32:    t63 = *((unsigned int *)t51);
    t64 = *((unsigned int *)t57);
    *((unsigned int *)t51) = (t63 | t64);
    t65 = (t14 + 4);
    t66 = (t45 + 4);
    t67 = *((unsigned int *)t14);
    t68 = (~(t67));
    t69 = *((unsigned int *)t65);
    t70 = (~(t69));
    t71 = *((unsigned int *)t45);
    t72 = (~(t71));
    t73 = *((unsigned int *)t66);
    t74 = (~(t73));
    t24 = (t68 & t70);
    t27 = (t72 & t74);
    t75 = (~(t24));
    t76 = (~(t27));
    t77 = *((unsigned int *)t57);
    *((unsigned int *)t57) = (t77 & t75);
    t78 = *((unsigned int *)t57);
    *((unsigned int *)t57) = (t78 & t76);
    t79 = *((unsigned int *)t51);
    *((unsigned int *)t51) = (t79 & t75);
    t80 = *((unsigned int *)t51);
    *((unsigned int *)t51) = (t80 & t76);
    goto LAB34;

LAB35:    xsi_set_current_line(39, ng0);
    t87 = (t0 + 2008U);
    t88 = *((char **)t87);
    t87 = (t0 + 2728);
    t91 = (t0 + 2728);
    t92 = (t91 + 72U);
    t93 = *((char **)t92);
    t94 = (t0 + 2728);
    t95 = (t94 + 64U);
    t96 = *((char **)t95);
    t97 = (t0 + 1848U);
    t98 = *((char **)t97);
    xsi_vlog_generic_convert_array_indices(t89, t90, t93, t96, 2, 1, t98, 5, 2);
    t97 = (t89 + 4);
    t99 = *((unsigned int *)t97);
    t28 = (!(t99));
    t100 = (t90 + 4);
    t101 = *((unsigned int *)t100);
    t31 = (!(t101));
    t32 = (t28 && t31);
    if (t32 == 1)
        goto LAB38;

LAB39:    goto LAB37;

LAB38:    t102 = *((unsigned int *)t89);
    t103 = *((unsigned int *)t90);
    t104 = (t102 - t103);
    t105 = (t104 + 1);
    xsi_vlogvar_wait_assign_value(t87, t88, 0, *((unsigned int *)t90), t105, 0LL);
    goto LAB39;

LAB40:    t8 = *((unsigned int *)t14);
    t9 = *((unsigned int *)t44);
    t31 = (t8 - t9);
    t32 = (t31 + 1);
    xsi_vlogvar_wait_assign_value(t18, t13, 0, *((unsigned int *)t44), t32, 0LL);
    goto LAB41;

}


extern void work_m_00000000004063732289_3979545863_init()
{
	static char *pe[] = {(void *)Cont_29_0,(void *)Cont_30_1,(void *)Always_33_2};
	xsi_register_didat("work_m_00000000004063732289_3979545863", "isim/CPU_TEST_MODULE_10_isim_beh.exe.sim/work/m_00000000004063732289_3979545863.didat");
	xsi_register_executes(pe);
}
