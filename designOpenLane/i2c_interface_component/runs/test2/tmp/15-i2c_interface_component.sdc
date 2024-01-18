###############################################################################
# Created by write_sdc
# Tue Jan  9 19:31:39 2024
###############################################################################
current_design i2c_interface_component
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name p_clock -period 10.0000 [get_ports {p_clock}]
set_clock_transition 0.1500 [get_clocks {p_clock}]
set_clock_uncertainty 0.2500 p_clock
set_propagated_clock [get_clocks {p_clock}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {SCL}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {SDA}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {component_mode}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[0]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[1]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[2]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[3]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[4]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[5]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_addr_i[6]}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {i2c_read_e}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {m_start_dump}]
set_input_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {p_reset}]
set_output_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {SCL}]
set_output_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {SDA}]
set_output_delay 2.0000 -clock [get_clocks {p_clock}] -add_delay [get_ports {m_data_dump}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {SCL}]
set_load -pin_load 0.0334 [get_ports {SDA}]
set_load -pin_load 0.0334 [get_ports {m_data_dump}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {SCL}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {SDA}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {component_mode}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_read_e}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {m_start_dump}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {p_clock}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {p_reset}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {i2c_addr_i[0]}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 10.0000 [current_design]
