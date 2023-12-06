bind tb_i2c_component
    top_tb i_top (
        .p_clock(p_clock),
        .p_reset(p_reset),
        .component_mode1(component_mode1),
        .component_mode2(component_mode2),
        .m_start_dump(m_start_dump),
        .m_data_dump1(m_data_dump),
        .m_data_dump2(m_data_dump),
        .i2c_addr_i1(i2c_addr_i),
        .i2c_addr_i2(i2c_addr_i),
        .i2c_read_e(i2c_read_e),
        .SCL(SCL),
        .SDA(SDA)
    );