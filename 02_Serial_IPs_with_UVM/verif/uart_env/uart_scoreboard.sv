`ifndef UART_SCOREBOARD_SV
`define UART_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`uvm_analysis_imp_decl(_rx_exp)
`uvm_analysis_imp_decl(_rx_act)
`uvm_analysis_imp_decl(_tx_exp)
`uvm_analysis_imp_decl(_tx_act)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_rx_exp #(uart_seq_item, uart_scoreboard) imp_rx_exp;
    uvm_analysis_imp_rx_act #(uart_seq_item, uart_scoreboard) imp_rx_act;
    uvm_analysis_imp_tx_exp #(uart_seq_item, uart_scoreboard) imp_tx_exp;
    uvm_analysis_imp_tx_act #(uart_seq_item, uart_scoreboard) imp_tx_act;

    uart_seq_item rx_exp_q[$];
    uart_seq_item tx_exp_q[$];

    int num_errors = 0; 

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp_rx_exp = new("imp_rx_exp", this);
        imp_rx_act = new("imp_rx_act", this);
        imp_tx_exp = new("imp_tx_exp", this);
        imp_tx_act = new("imp_tx_act", this);
    endfunction

    // DUT RX verification )
    virtual function void write_rx_exp(uart_seq_item item);
        rx_exp_q.push_back(item); 
    endfunction

    virtual function void write_rx_act(uart_seq_item act_item);
        uart_seq_item exp_item;
        
        if (rx_exp_q.size() > 0) begin
            exp_item = rx_exp_q.pop_front(); 
            
            if (exp_item.tx_data !== act_item.rx_data) begin
                `uvm_error("SB_RX", $sformatf("FAIL! exp: 0x%02h, act: 0x%02h", exp_item.tx_data, act_item.rx_data))
                num_errors++;
            end else begin
                `uvm_info("SB_RX", $sformatf("PASS! exp: 0x%02h, act: 0x%02h", exp_item.tx_data, act_item.rx_data), UVM_LOW)
            end
        end else begin
            `uvm_error("SB_RX", "rx_exp_q empty!")
        end
    endfunction

    // TX verification 
    virtual function void write_tx_exp(uart_seq_item item);
        tx_exp_q.push_back(item);
    endfunction

    virtual function void write_tx_act(uart_seq_item act_item);
        uart_seq_item exp_item;
        
        if (tx_exp_q.size() > 0) begin
            exp_item = tx_exp_q.pop_front(); 
            
            if (exp_item.tx_data !== act_item.rx_data) begin
                `uvm_error("SB_TX", $sformatf("FAIL! exp: 0x%02h, act: 0x%02h", exp_item.tx_data, act_item.rx_data))
                num_errors++;
            end else begin
                `uvm_info("SB_TX", $sformatf("PASS! exp: 0x%02h, act: 0x%02h", exp_item.tx_data, act_item.rx_data), UVM_LOW)
            end
        end else begin
            `uvm_error("SB_TX", "tx_exp_q empty!")
        end
    endfunction

  
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (num_errors == 0)
            `uvm_info("SB_REPORT", "=== UART verification (0 Errors) ===", UVM_NONE)
        else
            `uvm_error("SB_REPORT", $sformatf("=== UART verification failed... (%0d Errors) ===", num_errors))
    endfunction

endclass

`endif