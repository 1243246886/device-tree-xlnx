##############################################################################
variable phy_count 0
##############################################################################

proc gen_mdio_node {drv_handle} {
    set mdio_child_name "mdio"
    set mdio [hsm::utils::add_new_child_node $drv_handle $mdio_child_name]
    hsm::utils::add_new_property $mdio "#address-cells" int 1
    hsm::utils::add_new_property  $mdio "#size-cells" int 0
    return $mdio
}

proc ps7_reset_handle {drv_handle reset_pram conf_prop} {
    set ip [get_cells $drv_handle]
    set value [get_property CONFIG.${reset_pram} $ip]
    # workaround for reset not been selected
    regsub -all "<Select>" $value "" value
    if { [llength $value] } {
        regsub -all "MIO( |)" $value "" value
        if { $value != "-1" && [llength $value] !=0  } {
            set_property CONFIG.${conf_prop} "ps7_gpio_0 $value 0" $drv_handle
        }
    }
}


proc generate {drv_handle} {
     gen_mdio_node $drv_handle

    set slave [get_cells $drv_handle]
    set phymode [get_ip_param_value $slave "C_ETH_MODE"]
    if { $phymode == 0 } {
        set_property CONFIG.phy-mode "gmii" $drv_handle
    } else {
        set_property CONFIG.phy-mode "rgmii-id" $drv_handle
    }

    set hwproc [get_cells [get_sw_processor]]
    if { [llength [get_sw_processor] ] && [llength $hwproc] } {
        set ps7_cortexa9_1x_clk [get_ip_param_value $hwproc "C_CPU_1X_CLK_FREQ_HZ"]
        set_property CONFIG.xlnx,ptp-enet-clock "$ps7_cortexa9_1x_clk" $drv_handle
    }
    ps7_reset_handle $drv_handle C_ENET_RESET enet-reset
}


