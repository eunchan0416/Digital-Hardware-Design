`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_base_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_base_sequence)

    function new(string name = "uart_base_sequence");
        super.new(name);
    endfunction
    
    //  DUT RX(Driver is tx)
    task do_rx_test(bit [7:0] input_data); 
        uart_seq_item item;
        item = uart_seq_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
            test_type == RX_TEST; 
            tx_start  == 1'b0;    
            tx_data   == input_data; 
        }) `uvm_fatal(get_type_name(), "do_rx_test() randomize fail")
        finish_item(item);

        `uvm_info(get_type_name(),
                  $sformatf("do_rx_test finish : payload = 0x%02h", input_data), UVM_MEDIUM)
    endtask

    //  DUT TX (tx start & data create))
    task do_tx_test(bit [7:0] input_data); 
        uart_seq_item item;
        item = uart_seq_item::type_id::create("item");
        start_item(item);
        if (!item.randomize() with {
            test_type == TX_TEST; 
          tx_start  == 1'b1;   
            tx_data   == input_data; 
        }) `uvm_fatal(get_type_name(), "do_tx_test() randomize fail")
        finish_item(item);

        `uvm_info(get_type_name(),
                  $sformatf("do_tx_test finish : tx_data = 0x%02h", input_data), UVM_MEDIUM)
    endtask
endclass


class uart_rx_tx_sequence extends uart_base_sequence;
    `uvm_object_utils(uart_rx_tx_sequence)
    
    int num_loop =1;

    function new(string name = "uart_rx_tx_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // RX test
        `uvm_info(get_type_name(), $sformatf("Starting RX test with %0d iterations", num_loop), UVM_LOW)
          repeat (num_loop) begin
            do_rx_test($urandom_range(0,255));

        end
       `uvm_info(get_type_name(), "RX test completed", UVM_LOW)
        
        // TX test
        `uvm_info(get_type_name(), $sformatf("Starting TX test with %0d iterations", num_loop), UVM_LOW)
          repeat (num_loop) begin
        do_tx_test($urandom_range(0,255));
        end
        `uvm_info(get_type_name(), "TX test completed", UVM_LOW)
    endtask

endclass
`endif