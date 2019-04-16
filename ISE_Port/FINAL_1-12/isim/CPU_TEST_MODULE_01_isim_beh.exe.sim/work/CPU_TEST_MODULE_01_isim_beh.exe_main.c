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

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_00000000001338184453_2124486683_init();
    work_m_00000000002377893914_0105809609_init();
    work_m_00000000000514291867_2321183677_init();
    work_m_00000000001813274490_0909038331_init();
    work_m_00000000000733266532_0143406005_init();
    work_m_00000000000058807140_1926972201_init();
    work_m_00000000003884689914_2722733084_init();
    work_m_00000000003884689914_2966759537_init();
    work_m_00000000003391643285_1553826200_init();
    work_m_00000000003348457920_1317972029_init();
    work_m_00000000004063732289_3979545863_init();
    work_m_00000000002393936260_2188628963_init();
    work_m_00000000004127318473_2212205965_init();
    work_m_00000000003602668544_4126067407_init();
    work_m_00000000004179981650_3878975312_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000004179981650_3878975312");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
