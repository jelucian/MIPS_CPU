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
static const char *ng0 = "C:/Users/Jesus Luciano/Desktop/ISE_Port/test/IU.v";
static int ng1[] = {16, 0};
static unsigned int ng2[] = {0U, 0U};
static unsigned int ng3[] = {1U, 0U};



static void Cont_42_0(char *t0)
{
    char t3[8];
    char t4[8];
    char t13[8];
    char t17[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t14;
    char *t15;
    char *t16;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;
    char *t30;

LAB0:    t1 = (t0 + 4608U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(42, ng0);
    t2 = (t0 + 2808U);
    t5 = *((char **)t2);
    memset(t4, 0, 8);
    t2 = (t4 + 4);
    t6 = (t5 + 4);
    t7 = *((unsigned int *)t5);
    t8 = (t7 >> 0);
    *((unsigned int *)t4) = t8;
    t9 = *((unsigned int *)t6);
    t10 = (t9 >> 0);
    *((unsigned int *)t2) = t10;
    t11 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t11 & 65535U);
    t12 = *((unsigned int *)t2);
    *((unsigned int *)t2) = (t12 & 65535U);
    t14 = ((char*)((ng1)));
    t15 = (t0 + 2808U);
    t16 = *((char **)t15);
    memset(t17, 0, 8);
    t15 = (t17 + 4);
    t18 = (t16 + 4);
    t19 = *((unsigned int *)t16);
    t20 = (t19 >> 15);
    t21 = (t20 & 1);
    *((unsigned int *)t17) = t21;
    t22 = *((unsigned int *)t18);
    t23 = (t22 >> 15);
    t24 = (t23 & 1);
    *((unsigned int *)t15) = t24;
    xsi_vlog_mul_concat(t13, 16, 1, t14, 1U, t17, 1);
    xsi_vlogtype_concat(t3, 32, 32, 2U, t13, 16, t4, 16);
    t25 = (t0 + 5520);
    t26 = (t25 + 56U);
    t27 = *((char **)t26);
    t28 = (t27 + 56U);
    t29 = *((char **)t28);
    memcpy(t29, t3, 8);
    xsi_driver_vfirst_trans(t25, 0, 31);
    t30 = (t0 + 5424);
    *((int *)t30) = 1;

LAB1:    return;
}

static void Cont_45_1(char *t0)
{
    char t3[8];
    char t4[8];
    char t6[8];
    char t35[8];
    char t36[8];
    char t46[8];
    char t51[8];
    char t52[8];
    char t55[8];
    char t82[8];
    char t84[8];
    char t94[8];
    char *t1;
    char *t2;
    char *t5;
    char *t7;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    char *t33;
    char *t34;
    char *t37;
    char *t38;
    char *t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    char *t53;
    char *t54;
    char *t56;
    char *t57;
    unsigned int t58;
    unsigned int t59;
    unsigned int t60;
    unsigned int t61;
    unsigned int t62;
    unsigned int t63;
    unsigned int t64;
    unsigned int t65;
    unsigned int t66;
    unsigned int t67;
    unsigned int t68;
    unsigned int t69;
    char *t70;
    char *t71;
    unsigned int t72;
    unsigned int t73;
    unsigned int t74;
    unsigned int t75;
    unsigned int t76;
    char *t77;
    char *t78;
    unsigned int t79;
    unsigned int t80;
    unsigned int t81;
    char *t83;
    char *t85;
    char *t86;
    char *t87;
    unsigned int t88;
    unsigned int t89;
    unsigned int t90;
    unsigned int t91;
    unsigned int t92;
    unsigned int t93;
    char *t95;
    char *t96;
    char *t97;
    unsigned int t98;
    unsigned int t99;
    unsigned int t100;
    unsigned int t101;
    unsigned int t102;
    unsigned int t103;
    unsigned int t104;
    unsigned int t105;
    unsigned int t106;
    unsigned int t107;
    char *t108;
    char *t109;
    char *t110;
    char *t111;
    char *t112;
    char *t113;
    char *t114;

LAB0:    t1 = (t0 + 4856U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 2328U);
    t5 = *((char **)t2);
    t2 = ((char*)((ng2)));
    memset(t6, 0, 8);
    t7 = (t5 + 4);
    t8 = (t2 + 4);
    t9 = *((unsigned int *)t5);
    t10 = *((unsigned int *)t2);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t7);
    t13 = *((unsigned int *)t8);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t7);
    t17 = *((unsigned int *)t8);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB7;

LAB4:    if (t18 != 0)
        goto LAB6;

LAB5:    *((unsigned int *)t6) = 1;

LAB7:    memset(t4, 0, 8);
    t22 = (t6 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 & 1U);
    if (t27 != 0)
        goto LAB8;

LAB9:    if (*((unsigned int *)t22) != 0)
        goto LAB10;

LAB11:    t29 = (t4 + 4);
    t30 = *((unsigned int *)t4);
    t31 = *((unsigned int *)t29);
    t32 = (t30 || t31);
    if (t32 > 0)
        goto LAB12;

LAB13:    t47 = *((unsigned int *)t4);
    t48 = (~(t47));
    t49 = *((unsigned int *)t29);
    t50 = (t48 || t49);
    if (t50 > 0)
        goto LAB14;

LAB15:    if (*((unsigned int *)t29) > 0)
        goto LAB16;

LAB17:    if (*((unsigned int *)t4) > 0)
        goto LAB18;

LAB19:    memcpy(t3, t51, 8);

LAB20:    t108 = (t0 + 5584);
    t110 = (t108 + 56U);
    t111 = *((char **)t110);
    t112 = (t111 + 56U);
    t113 = *((char **)t112);
    memcpy(t113, t3, 8);
    xsi_driver_vfirst_trans(t108, 0, 31);
    t114 = (t0 + 5440);
    *((int *)t114) = 1;

LAB1:    return;
LAB6:    t21 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB7;

LAB8:    *((unsigned int *)t4) = 1;
    goto LAB11;

LAB10:    t28 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t28) = 1;
    goto LAB11;

LAB12:    t33 = (t0 + 2648U);
    t34 = *((char **)t33);
    t33 = ((char*)((ng2)));
    t37 = (t0 + 2968U);
    t38 = *((char **)t37);
    memset(t36, 0, 8);
    t37 = (t36 + 4);
    t39 = (t38 + 4);
    t40 = *((unsigned int *)t38);
    t41 = (t40 >> 0);
    *((unsigned int *)t36) = t41;
    t42 = *((unsigned int *)t39);
    t43 = (t42 >> 0);
    *((unsigned int *)t37) = t43;
    t44 = *((unsigned int *)t36);
    *((unsigned int *)t36) = (t44 & 1073741823U);
    t45 = *((unsigned int *)t37);
    *((unsigned int *)t37) = (t45 & 1073741823U);
    xsi_vlogtype_concat(t35, 32, 32, 2U, t36, 30, t33, 2);
    memset(t46, 0, 8);
    xsi_vlog_unsigned_add(t46, 32, t34, 32, t35, 32);
    goto LAB13;

LAB14:    t53 = (t0 + 2328U);
    t54 = *((char **)t53);
    t53 = ((char*)((ng3)));
    memset(t55, 0, 8);
    t56 = (t54 + 4);
    t57 = (t53 + 4);
    t58 = *((unsigned int *)t54);
    t59 = *((unsigned int *)t53);
    t60 = (t58 ^ t59);
    t61 = *((unsigned int *)t56);
    t62 = *((unsigned int *)t57);
    t63 = (t61 ^ t62);
    t64 = (t60 | t63);
    t65 = *((unsigned int *)t56);
    t66 = *((unsigned int *)t57);
    t67 = (t65 | t66);
    t68 = (~(t67));
    t69 = (t64 & t68);
    if (t69 != 0)
        goto LAB24;

LAB21:    if (t67 != 0)
        goto LAB23;

LAB22:    *((unsigned int *)t55) = 1;

LAB24:    memset(t52, 0, 8);
    t71 = (t55 + 4);
    t72 = *((unsigned int *)t71);
    t73 = (~(t72));
    t74 = *((unsigned int *)t55);
    t75 = (t74 & t73);
    t76 = (t75 & 1U);
    if (t76 != 0)
        goto LAB25;

LAB26:    if (*((unsigned int *)t71) != 0)
        goto LAB27;

LAB28:    t78 = (t52 + 4);
    t79 = *((unsigned int *)t52);
    t80 = *((unsigned int *)t78);
    t81 = (t79 || t80);
    if (t81 > 0)
        goto LAB29;

LAB30:    t104 = *((unsigned int *)t52);
    t105 = (~(t104));
    t106 = *((unsigned int *)t78);
    t107 = (t105 || t106);
    if (t107 > 0)
        goto LAB31;

LAB32:    if (*((unsigned int *)t78) > 0)
        goto LAB33;

LAB34:    if (*((unsigned int *)t52) > 0)
        goto LAB35;

LAB36:    memcpy(t51, t109, 8);

LAB37:    goto LAB15;

LAB16:    xsi_vlog_unsigned_bit_combine(t3, 32, t46, 32, t51, 32);
    goto LAB20;

LAB18:    memcpy(t3, t46, 8);
    goto LAB20;

LAB23:    t70 = (t55 + 4);
    *((unsigned int *)t55) = 1;
    *((unsigned int *)t70) = 1;
    goto LAB24;

LAB25:    *((unsigned int *)t52) = 1;
    goto LAB28;

LAB27:    t77 = (t52 + 4);
    *((unsigned int *)t52) = 1;
    *((unsigned int *)t77) = 1;
    goto LAB28;

LAB29:    t83 = ((char*)((ng2)));
    t85 = (t0 + 2808U);
    t86 = *((char **)t85);
    memset(t84, 0, 8);
    t85 = (t84 + 4);
    t87 = (t86 + 4);
    t88 = *((unsigned int *)t86);
    t89 = (t88 >> 0);
    *((unsigned int *)t84) = t89;
    t90 = *((unsigned int *)t87);
    t91 = (t90 >> 0);
    *((unsigned int *)t85) = t91;
    t92 = *((unsigned int *)t84);
    *((unsigned int *)t84) = (t92 & 67108863U);
    t93 = *((unsigned int *)t85);
    *((unsigned int *)t85) = (t93 & 67108863U);
    t95 = (t0 + 2648U);
    t96 = *((char **)t95);
    memset(t94, 0, 8);
    t95 = (t94 + 4);
    t97 = (t96 + 4);
    t98 = *((unsigned int *)t96);
    t99 = (t98 >> 28);
    *((unsigned int *)t94) = t99;
    t100 = *((unsigned int *)t97);
    t101 = (t100 >> 28);
    *((unsigned int *)t95) = t101;
    t102 = *((unsigned int *)t94);
    *((unsigned int *)t94) = (t102 & 15U);
    t103 = *((unsigned int *)t95);
    *((unsigned int *)t95) = (t103 & 15U);
    xsi_vlogtype_concat(t82, 32, 32, 3U, t94, 4, t84, 26, t83, 2);
    goto LAB30;

LAB31:    t108 = (t0 + 2488U);
    t109 = *((char **)t108);
    goto LAB32;

LAB33:    xsi_vlog_unsigned_bit_combine(t51, 32, t82, 32, t109, 32);
    goto LAB37;

LAB35:    memcpy(t51, t82, 8);
    goto LAB37;

}

static void implSig1_execute(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    t1 = (t0 + 5104U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    t2 = ((char*)((ng2)));
    t3 = (t0 + 5648);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t2, 8);
    xsi_driver_vfirst_trans(t3, 0, 31);

LAB1:    return;
}


extern void work_m_00000000000733266532_0143406005_init()
{
	static char *pe[] = {(void *)Cont_42_0,(void *)Cont_45_1,(void *)implSig1_execute};
	xsi_register_didat("work_m_00000000000733266532_0143406005", "isim/CPU_TEST_MODULE_11_isim_beh.exe.sim/work/m_00000000000733266532_0143406005.didat");
	xsi_register_executes(pe);
}
