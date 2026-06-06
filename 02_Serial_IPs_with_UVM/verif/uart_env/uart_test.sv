`ifndef UART_BASE_TEST_SV
`define UART_BASE_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    uart_env env;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "======= UVM Structure Architecture =======", UVM_NONE)
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        uart_rx_tx_sequence seq; 
        super.run_phase(phase);
        
        
        phase.raise_objection(this);
        
        seq = uart_rx_tx_sequence::type_id::create("seq");
        seq.num_loop = 10; 
        seq.start(env.agt.sqr);
        
      
        phase.drop_objection(this);
    endtask

endclass

`endif
