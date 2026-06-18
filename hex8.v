module hex8
(
    input clk,
    input reset_n,
    input en,
    input [31:0] disp_data,
    output reg [7:0] sel,
    output reg [6:0] seg
);
reg [14:0] scan_cnt;
wire scan_tick;
assign scan_tick = (scan_cnt == 15'd24999);
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        scan_cnt <= 15'd0;
    else if (!en)
        scan_cnt <= 15'd0;
    else if (scan_tick)
        scan_cnt <= 15'd0;
    else
        scan_cnt <= scan_cnt + 15'd1;
end
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        sel <= 8'b0000_0001;
    else if (!en)
        sel <= 8'b0000_0000;
    else if (scan_tick)
    begin
        if (sel == 8'b1000_0000)
            sel <= 8'b0000_0001;
        else
            sel <= sel << 1;
    end
end
reg [3:0] data_tmp;
always @(*)
begin
    case (sel)
        8'b0000_0001: data_tmp = disp_data[3:0];
        8'b0000_0010: data_tmp = disp_data[7:4];
        8'b0000_0100: data_tmp = disp_data[11:8];
        8'b0000_1000: data_tmp = disp_data[15:12];
        8'b0001_0000: data_tmp = disp_data[19:16];
        8'b0010_0000: data_tmp = disp_data[23:20];
        8'b0100_0000: data_tmp = disp_data[27:24];
        8'b1000_0000: data_tmp = disp_data[31:28];
        default:      data_tmp = 4'd0;
    endcase
end
always @(*)
begin
    case (data_tmp)
        4'h0: seg = 7'b1000000;
        4'h1: seg = 7'b1111001;
        4'h2: seg = 7'b0100100;
        4'h3: seg = 7'b0110000;
        4'h4: seg = 7'b0011001;
        4'h5: seg = 7'b0010010;
        4'h6: seg = 7'b0000010;
        4'h7: seg = 7'b1111000;
        4'h8: seg = 7'b0000000;
        4'h9: seg = 7'b0010000;
        4'ha: seg = 7'b0001000;
        4'hb: seg = 7'b0000011;
        4'hc: seg = 7'b1000110;
        4'hd: seg = 7'b0100001;
        4'he: seg = 7'b0000110;
        4'hf: seg = 7'b0001110;
        default: seg = 7'b1111111;
    endcase
end
endmodule