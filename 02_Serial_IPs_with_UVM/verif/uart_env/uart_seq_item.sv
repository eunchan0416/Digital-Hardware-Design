`ifndef UART_SEQ_ITEM_SV

`define UART_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class uart_seq_item extends uvm_sequence_item;
    `uvm_object_utils(uart_seq_item)

    typedef enum bit {RX_TEST, TX_TEST} test_e;
    
    rand test_e test_type; 
    
    rand logic uart_rx;
    rand logic tx_start;
    rand logic [7:0] tx_data; 

    logic uart_tx;
    logic tx_busy;
    logic tx_done;
    logic rx_done;
    logic [7:0] rx_data;      

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
       
        return $sformatf( 
            " [%s] tx_data=0x%02h, tx_done=%01b, rx_data=0x%02h rx_done=%01b",
            test_type.name(),
            tx_data,
            tx_done,
            rx_data,
            rx_done
        );
    endfunction

endclass



`endif


