`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if u_if;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this,"","u_if",u_if)) begin
            `uvm_fatal(get_type_name(), "can't get uart_if")
        end
    endfunction

    task uart_init();
        u_if.drv_cb.uart_rx <= 1; 
        u_if.drv_cb.tx_start <= 0;
        u_if.drv_cb.tx_data <= 0;
    endtask

    // DUT RX Test (Driver tx , data trnasfer)
    task drive_tx(uart_seq_item item);
        int baud_cycles = 100_000_000 / 9600;
    `uvm_info(get_type_name(), $sformatf("drive_tx [START]: Sending data = 0x%02h", item.tx_data), UVM_MEDIUM)
        @(u_if.drv_cb);
        // Start bit
        u_if.drv_cb.uart_rx <= 0; 
        repeat(baud_cycles) @(u_if.drv_cb);

        // Data bits
        for(int i=0; i<8; i++) begin
            u_if.drv_cb.uart_rx <= item.tx_data[i];
            repeat(baud_cycles) @(u_if.drv_cb);
        end

        // Stop bit
        u_if.drv_cb.uart_rx <= 1;
        repeat(baud_cycles) @(u_if.drv_cb);
   `uvm_info(get_type_name(), $sformatf("drive_tx [END]: Finished sending data = 0x%02h", item.tx_data), UVM_MEDIUM)
    endtask

    //  DUT TX Test (Driver tx start & data)
    task drive_rx(uart_seq_item item);
        int baud_cycles = 100_000_000 / 9600;

        `uvm_info(get_type_name(), $sformatf("drive_rx [START]: Starting TX with data = 0x%02h", item.tx_data), UVM_MEDIUM)
        @(u_if.drv_cb);
        u_if.drv_cb.tx_start <= 1;
        u_if.drv_cb.tx_data  <= item.tx_data;
        
        @(u_if.drv_cb);
        u_if.drv_cb.tx_start <= 0; 

        // DUT waiting (Start 1 + Data 8 + Stop 1 = 10 bit)
        repeat(baud_cycles * 10) @(u_if.drv_cb);
        `uvm_info(get_type_name(), $sformatf("drive_rx [END]: Finished TX with data = 0x%02h", item.tx_data), UVM_MEDIUM)
    endtask

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        uart_init();
        wait(u_if.rst == 0);
        `uvm_info(get_type_name(), "uart reset end ", UVM_LOW)

        forever begin
            uart_seq_item item;
            seq_item_port.get_next_item(item);
            
            case(item.test_type)
                uart_seq_item::RX_TEST: drive_tx(item); 
                uart_seq_item::TX_TEST: drive_rx(item);
            endcase
            
            seq_item_port.item_done();
        end
    endtask
endclass

`endif