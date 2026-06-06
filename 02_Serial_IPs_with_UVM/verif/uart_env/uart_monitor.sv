
`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)
    
    uvm_analysis_port #(uart_seq_item) ap_rx_exp; // RX golden  value(driver to dut)
    uvm_analysis_port #(uart_seq_item) ap_rx_act; // RX data (from DUT)
    uvm_analysis_port #(uart_seq_item) ap_tx_exp; // TX golden value(driver to dut)
    uvm_analysis_port #(uart_seq_item) ap_tx_act; // TX data (from DUT)

    virtual uart_if u_if;
    int baud_cycles = 100_000_000 / 9600; 
    
    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this,"","u_if",u_if))
            `uvm_fatal(get_type_name(), "can't get uart_if")
            
        
        ap_rx_exp = new("ap_rx_exp", this);
        ap_rx_act = new("ap_rx_act", this);
        ap_tx_exp = new("ap_tx_exp", this);
        ap_tx_act = new("ap_tx_act", this);
    endfunction

    //  RX golden value capture ,driver -> dut
    task monitor_rx_exp();
        forever begin
            @(u_if.mon_cb);
            if (u_if.mon_cb.uart_rx == 1'b0) begin 
                uart_seq_item item = uart_seq_item::type_id::create("item");
                repeat(baud_cycles / 2) @(u_if.mon_cb);
                for (int i=0; i<8; i++) begin
                    repeat(baud_cycles) @(u_if.mon_cb);
                    item.tx_data[i] = u_if.mon_cb.uart_rx; 
                end
                repeat(baud_cycles) @(u_if.mon_cb); 
                ap_rx_exp.write(item); 
                `uvm_info(get_type_name(), $sformatf("monitor_rx_exp: Captured expected RX data = 0x%02h", item.tx_data), UVM_MEDIUM)
            end
        end
    endtask

    //  RX result capture 
    task monitor_rx_act();
        forever begin
            @(u_if.mon_cb);
            if (u_if.mon_cb.rx_done == 1'b1) begin
                uart_seq_item item = uart_seq_item::type_id::create("item");
                item.rx_data = u_if.mon_cb.rx_data; 
                ap_rx_act.write(item); 
                `uvm_info(get_type_name(), $sformatf("monitor_rx_act: Captured actual RX data = 0x%02h", item.rx_data), UVM_MEDIUM)
            end
        end
    endtask

    //  TX golden value capture 
    task monitor_tx_exp();
        forever begin
            @(u_if.mon_cb);
            if (u_if.mon_cb.tx_start == 1'b1) begin
                uart_seq_item item = uart_seq_item::type_id::create("item");
                item.tx_data = u_if.mon_cb.tx_data; 
                ap_tx_exp.write(item);
                `uvm_info(get_type_name(), $sformatf("monitor_tx_exp: Captured expected TX data = 0x%02h", item.tx_data), UVM_MEDIUM) 
            end
        end
    endtask

    //  TX result capture 
    task monitor_tx_act();
        forever begin
            @(u_if.mon_cb);
            if (u_if.mon_cb.uart_tx == 1'b0) begin 
                uart_seq_item item = uart_seq_item::type_id::create("item");
                repeat(baud_cycles / 2) @(u_if.mon_cb);
                for (int i=0; i<8; i++) begin
                    repeat(baud_cycles) @(u_if.mon_cb);
                    item.rx_data[i] = u_if.mon_cb.uart_tx; 
                end
                repeat(baud_cycles) @(u_if.mon_cb); 
                ap_tx_act.write(item); 
                `uvm_info(get_type_name(), $sformatf("monitor_tx_act: Captured actual TX data = 0x%02h", item.rx_data), UVM_MEDIUM)
            end
        end
    endtask

   
    virtual task run_phase(uvm_phase phase);
        fork
            monitor_rx_exp();
            monitor_rx_act();
            monitor_tx_exp();
            monitor_tx_act();
        join
    endtask
endclass
`endif

