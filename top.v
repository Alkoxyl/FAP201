module Demux_LFSR_Project_Top (
    input i_Clk,
    input i_Reset_N,
    input i_Switch_1,
    input i_Switch_2,
    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4,
    output o_SEG7_DIO,
    output o_SEG7_RCLK,
    output o_SEG7_SCLK);
wire [1:0] w_LED_Select;
assign w_LED_Select = {i_Switch_2, i_Switch_1};
reg r_LFSR_Toggle = 1'b0;
wire w_LFSR_Done;
LFSR_22 LFSR_Inst(
    .i_Clk(i_Clk),
    .o_LFSR_Data(),
    .o_LFSR_Done(w_LFSR_Done));
reg r_LFSR_Done_Delay = 1'b0;
wire w_LFSR_Done_Pulse;
always @(posedge i_Clk or negedge i_Reset_N)
begin
    if (!i_Reset_N)
        r_LFSR_Done_Delay <= 1'b0;
    else
        r_LFSR_Done_Delay <= w_LFSR_Done;
end
assign w_LFSR_Done_Pulse = w_LFSR_Done & ~r_LFSR_Done_Delay;
Demux_1_To_4 Demux_Inst(
    .i_Data(r_LFSR_Toggle),
    .i_Sel0(i_Switch_1),
    .i_Sel1(i_Switch_2),
    .o_Data0(o_LED_1),
    .o_Data1(o_LED_2),
    .o_Data2(o_LED_3),
    .o_Data3(o_LED_4));
reg [31:0] r_Count_LED1 = 32'h0000_0000;
reg [31:0] r_Count_LED2 = 32'h0000_0000;
reg [31:0] r_Count_LED3 = 32'h0000_0000;
reg [31:0] r_Count_LED4 = 32'h0000_0000;
function [31:0] bcd_inc8;
    input [31:0] value;
    reg [3:0] d0;
    reg [3:0] d1;
    reg [3:0] d2;
    reg [3:0] d3;
    reg [3:0] d4;
    reg [3:0] d5;
    reg [3:0] d6;
    reg [3:0] d7;
    begin
        d0 = value[3:0];
        d1 = value[7:4];
        d2 = value[11:8];
        d3 = value[15:12];
        d4 = value[19:16];
        d5 = value[23:20];
        d6 = value[27:24];
        d7 = value[31:28];
        if (d0 != 4'd9)
            d0 = d0 + 4'd1;
        else begin
            d0 = 4'd0;
            if (d1 != 4'd9)
                d1 = d1 + 4'd1;
            else begin
                d1 = 4'd0;
                if (d2 != 4'd9)
                    d2 = d2 + 4'd1;
                else begin
                    d2 = 4'd0;
                    if (d3 != 4'd9)
                        d3 = d3 + 4'd1;
                    else begin
                        d3 = 4'd0;
                        if (d4 != 4'd9)
                            d4 = d4 + 4'd1;
                        else begin
                            d4 = 4'd0;
                            if (d5 != 4'd9)
                                d5 = d5 + 4'd1;
                            else begin
                                d5 = 4'd0;
                                if (d6 != 4'd9)
                                    d6 = d6 + 4'd1;
                                else begin
                                    d6 = 4'd0;
                                    if (d7 != 4'd9)
                                        d7 = d7 + 4'd1;
                                    else
                                        d7 = 4'd0;
                                end
                            end
                        end
                    end
                end
            end
        end
        bcd_inc8 = {d7, d6, d5, d4, d3, d2, d1, d0};
    end
endfunction
always @(posedge i_Clk or negedge i_Reset_N)
begin
    if (!i_Reset_N)
    begin
        r_LFSR_Toggle <= 1'b0;
        r_Count_LED1 <= 32'h0000_0000;
        r_Count_LED2 <= 32'h0000_0000;
        r_Count_LED3 <= 32'h0000_0000;
        r_Count_LED4 <= 32'h0000_0000;
    end
    else if (w_LFSR_Done_Pulse)
    begin
        r_LFSR_Toggle <= ~r_LFSR_Toggle;
        if (r_LFSR_Toggle == 1'b0)
        begin
            case (w_LED_Select)
                2'b00:
                    r_Count_LED1 <= bcd_inc8(r_Count_LED1);
                2'b01:
                    r_Count_LED2 <= bcd_inc8(r_Count_LED2);
                2'b10:
                    r_Count_LED3 <= bcd_inc8(r_Count_LED3);
                2'b11:
                    r_Count_LED4 <= bcd_inc8(r_Count_LED4);
                default:
                    r_Count_LED1 <= r_Count_LED1;
            endcase
        end
    end
end
reg [31:0] r_Disp_Data;
always @(*)
begin
    case (w_LED_Select)
        2'b00: r_Disp_Data = r_Count_LED1;
        2'b01: r_Disp_Data = r_Count_LED2;
        2'b10: r_Disp_Data = r_Count_LED3;
        2'b11: r_Disp_Data = r_Count_LED4;
        default: r_Disp_Data = 32'h0000_0000;
    endcase
end
wire [6:0] w_Seg;
wire [7:0] w_Sel;
hex8 Hex8_Inst(
    .clk(i_Clk),
    .reset_n(i_Reset_N),
    .en(1'b1),
    .disp_data(r_Disp_Data),
    .sel(w_Sel),
    .seg(w_Seg));
hc595_driver Hc595_Inst(
    .clk(i_Clk),
    .reset_n(i_Reset_N),
    .en(1'b1),
    .data({1'b1, w_Seg, w_Sel}),
    .ds(o_SEG7_DIO),
    .sh_cp(o_SEG7_SCLK),
    .st_cp(o_SEG7_RCLK));
endmodule