module top_tb(
  p_clock,
  p_reset,
  component_mode1,
  component_mode2,
  m_start_dump,
  m_data_dump1,
  m_data_dump2,
  i2c_addr_i1,
  i2c_addr_i2,
  i2c_read_e,
  SCL,
  SDA
);
  // Declaração de sinais do testbench
  input p_clock, p_reset, component_mode1, component_mode2, m_start_dump, i2c_read_e;
  input  [6:0] i2c_addr_i1, i2c_addr_i2;
  output [7:0] m_data_dump1, m_data_dump2;
  inout SCL, SDA;

    default 
        clocking @(posedge p_clock);
    endclocking

    default disable iff !p_reset;

    initial begin
        m_start_dump <= 1'b0;

        component_mode1 <= 1'b0;
        i2c_addr_i1 <= "0000010";
        i2c_read_e <= 1'b0;

        component_mode2 <= 1'b1;
        i2c_addr_i2 <= "1100110";

    end

  // Propriedades de verificação

  /// PROPRIEDADE DE PARTIDA///////////////
  property p_start_condition;
    @(posedge SCL) disable iff (!p_reset)
    (SCL == 1'b1 && SDA == 1'b1) |-> (SCL ##1 SDA == 1'b0);
  endproperty;

  a_i2c_start : assert property (p_start_condition);
  c_i2c_start : cover property (p_start_condition);
  //////////////////////////////////////////

  /// PROPRIEDADE DE ENDEREÇAMENTO//////////
  property p_addressing_mode;
    @(posedge SCL) disable iff (!p_reset)
    (SCL == 1'b0 && SDA == 1'bX) |-> (SCL ##1 SDA == 1'bX) [*1:9];
  endproperty;

  a_i2c_addressing_mode : assert property (p_addressing_mode);
  c_i2c_addressing_mode : cover property (p_addressing_mode);
  //////////////////////////////////////////

  ////// PROPRIEDADE DE LEITURA E ESCRITA///
  property p_read_write_data;
    @(posedge SCL) disable iff (!p_reset)
    (SCL == 1'b0 && SDA == 1'bX) |-> (SCL ##1 SDA == 1'bX) [*1:8];
  endproperty;

  a_i2c_read_write_data : assert property (p_read_write_data);
  c_i2c_read_write_data : cover property (p_read_write_data);
  //////////////////////////////////////////

  ////// PROPRIEDADE DE ACKNOWLEDGE/////////
  property p_acknowledge;
    @(posedge SCL) disable iff (!p_reset)
    (SCL == 1'b0 && SDA == 1'bX) |-> (SCL ##1 SDA == 1'b0);
  endproperty;

  a_i2c_acknowledge : assert property (p_acknowledge);
  c_i2c_acknowledge : cover property (p_acknowledge);
  //////////////////////////////////////////

  ////// PROPRIEDADE DE STOP///////////////
  property p_stop_condition;
    @(posedge SCL) disable iff (!p_reset)
    (SCL == 1'b1 && SDA == 1'b0) |-> (SCL ##1 SDA == 1'b1);
  endproperty;

  a_i2c_stop : assert property (p_stop_condition);
  c_i2c_stop : cover property (p_stop_condition);
  //////////////////////////////////////////
endmodule