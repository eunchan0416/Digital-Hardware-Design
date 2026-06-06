`ifndef ENV_SV

`define ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;


class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agent agt;
    uart_scoreboard sb;

    function new(string name, uvm_component c);
    super.new(name, c);

    endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = uart_agent::type_id::create("agt", this);
    sb = uart_scoreboard::type_id::create("sb", this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.ap_rx_exp.connect(sb.imp_rx_exp);
    agt.mon.ap_rx_act.connect(sb.imp_rx_act);
    agt.mon.ap_tx_exp.connect(sb.imp_tx_exp);
    agt.mon.ap_tx_act.connect(sb.imp_tx_act);
    endfunction

    

endclass





`endif


