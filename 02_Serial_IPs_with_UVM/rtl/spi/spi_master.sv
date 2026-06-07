`timescale 1ns / 1ps

module spi_master (
    input  logic       clk,
    input  logic       reset,
    input  logic       cpol,     //mode contorl
    input  logic       cpha,     //mode control
    input  logic [7:0] clk_div,
    input  logic [7:0] tx_data,
    input  logic       start,
    output logic [7:0] rx_data,
    output logic       done,
    output logic       busy,
    output logic       sclk,
    output logic       mosi,
    input  logic       miso,
    input   logic [1:0] cs,
    output logic       cs_n0,
    output logic       cs_n1,
    output logic       cs_n2,
    output logic       cs_n3
);

    typedef enum logic [1:0] {
        IDLE  = 2'd0,
        START,
        DATA,
        STOP
    } spi_st_e;

    spi_st_e       state;

    logic    [7:0] div_cnt;
    logic          half_tick;
    logic    [3:0] bit_cnt;
    logic          phase;
    logic    [7:0] tx_shift_reg;
    logic    [7:0] rx_shift_reg;
    logic          sclk_r;
    logic [1:0] cs_r;
    logic cpol_r;
    logic cpha_r;
    assign sclk = sclk_r;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            div_cnt   <= 0;
            half_tick <= 0;

        end else begin
            if (state == DATA) begin
                if (div_cnt == clk_div) begin
                    div_cnt   <= 0;
                    half_tick <= 1;

                end else begin
                    div_cnt   <= div_cnt + 1;
                    half_tick <= 0;

                end

            end else begin
                div_cnt   <= 0;
                half_tick <= 0;
            end
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            done         <= 0;
            busy         <= 0;
            mosi         <= 1;
            cs_n0         <= 1;
            cs_n1         <= 1;
            cs_n2         <= 1;
            cs_n3         <= 1;
            tx_shift_reg <= 0;
            rx_shift_reg <= 0;
            bit_cnt      <= 0;
            phase        <= 0;
            rx_data      <= 0;
            sclk_r       <= 0;
            cs_r<=2'd0;
            cpol_r<=0;
            cpha_r<=0;
        end else begin
            done <= 0;


            case (state)
                IDLE: begin
                    cs_r<=cs;
                    mosi   <= 1;
                    cs_n0   <= 1;
                    cs_n1   <= 1;
                    cs_n2   <= 1;
                    cs_n3   <= 1;
                    sclk_r <= cpol;
                    cpha_r<=cpha;
                    cpol_r<=cpol;
                    if (start) begin
                        tx_shift_reg <= tx_data;
                        bit_cnt <= 0;
                        phase <= 0;
                        busy <= 1;
                        cpol_r<=cpol;
                        state <= START;
                        sclk_r <= cpol;
                        cs_r<=cs;
                        cpha_r<=cpha;
                        case(cs) 
                        2'd0:cs_n0 <= 0;
                        2'd1:cs_n1 <= 0;
                        2'd2:cs_n2 <= 0;
                        2'd3:cs_n3 <= 0;
                        
                        default: begin
                            
                        end
                        endcase
                    end
                end
                START: begin
                    state <= DATA;
                    if (cpha_r == 0) begin
                        mosi <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                end
                DATA: begin
                    if (half_tick) begin

                        if (cpha_r == 0) begin
                            sclk_r <= ~sclk_r;

                            if (phase == 0) begin
                                // 1st edge (Capture)
                                phase <= 1;
                                rx_shift_reg <=  {rx_shift_reg[6:0], miso};
                            end else begin
                                // 2nd edge (Shift & Check STOP)
                                phase <= 0;
                                if (bit_cnt < 7) begin
                                    mosi <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                    bit_cnt <= bit_cnt + 1;
                                end else if (bit_cnt == 7) begin
                                    state   <= STOP;
                                    rx_data <= rx_shift_reg;
                                    bit_cnt <= 0;
                                end
                            end

                        end else begin

                            if (phase == 0) begin
                                // 1st edge (Shift)

                                if (bit_cnt == 8) begin
                                    state   <= STOP;
                                    sclk_r  <= cpol_r;
                                    bit_cnt <= 0;
                                    rx_data <= rx_shift_reg;
                                end else begin
                                    //  (Shift)
                                    sclk_r <= ~sclk_r;
                                    phase <= 1;
                                    mosi <= tx_shift_reg[7];
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                end

                            end else begin
                                // 2nd edge  (Capture) 
                                sclk_r <= ~sclk_r;
                                phase <= 0;
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                                bit_cnt <= bit_cnt + 1;

                            end
                        end  
                    end
                end
                STOP: begin
                    sclk_r <= cpol_r;
                    done   <= 1;
                    busy   <= 0;
                    mosi   <= 1;
                    state  <= IDLE;
                    case(cs_r) 
                        2'd0:cs_n0 <= 1;
                        2'd1:cs_n1 <= 1;
                        2'd2:cs_n2 <= 1;
                        2'd3:cs_n3 <= 1;
                        
                        default: begin
                            
                        end
                        endcase
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end


endmodule


