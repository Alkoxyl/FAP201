module hc595_driver #(parameter CNT_MAX = 4)(
    input clk,
    input reset_n,
    input en,
    input [15:0] data,
    output reg ds,
    output reg sh_cp,
    output reg st_cp);
reg [7:0] divider_cnt;
wire sck_plus;
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        divider_cnt <= 8'd0;
    else if (divider_cnt == CNT_MAX - 1)
        divider_cnt <= 8'd0;
    else
        divider_cnt <= divider_cnt + 8'd1;
end
assign sck_plus = (divider_cnt == CNT_MAX - 1);
reg [15:0] r_data;
reg [5:0] bit_state;
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
    begin
        r_data    <= 16'd0;
        bit_state <= 6'd0;
        ds        <= 1'b0;
        sh_cp     <= 1'b0;
        st_cp     <= 1'b0;
    end
    else if (!en)
    begin
        bit_state <= 6'd0;
        ds        <= 1'b0;
        sh_cp     <= 1'b0;
        st_cp     <= 1'b0;
    end
    else if (sck_plus)
    begin
        case (bit_state)
            6'd0:
            begin
                r_data <= data;
                sh_cp  <= 1'b0;
                st_cp  <= 1'b0;
                bit_state <= 6'd1;
            end
            6'd1:
            begin
                ds <= r_data[15];
                sh_cp <= 1'b0;
                bit_state <= 6'd2;
            end
            6'd2:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd3;
            end
            6'd3:
            begin
                ds <= r_data[14];
                sh_cp <= 1'b0;
                bit_state <= 6'd4;
            end
            6'd4:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd5;
            end
            6'd5:
            begin
                ds <= r_data[13];
                sh_cp <= 1'b0;
                bit_state <= 6'd6;
            end
            6'd6:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd7;
            end
            6'd7:
            begin
                ds <= r_data[12];
                sh_cp <= 1'b0;
                bit_state <= 6'd8;
            end
            6'd8:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd9;
            end
            6'd9:
            begin
                ds <= r_data[11];
                sh_cp <= 1'b0;
                bit_state <= 6'd10;
            end
            6'd10:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd11;
            end
            6'd11:
            begin
                ds <= r_data[10];
                sh_cp <= 1'b0;
                bit_state <= 6'd12;
            end
            6'd12:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd13;
            end
            6'd13:
            begin
                ds <= r_data[9];
                sh_cp <= 1'b0;
                bit_state <= 6'd14;
            end
            6'd14:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd15;
            end
            6'd15:
            begin
                ds <= r_data[8];
                sh_cp <= 1'b0;
                bit_state <= 6'd16;
            end
            6'd16:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd17;
            end
            6'd17:
            begin
                ds <= r_data[7];
                sh_cp <= 1'b0;
                bit_state <= 6'd18;
            end
            6'd18:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd19;
            end
            6'd19:
            begin
                ds <= r_data[6];
                sh_cp <= 1'b0;
                bit_state <= 6'd20;
            end
            6'd20:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd21;
            end
            6'd21:
            begin
                ds <= r_data[5];
                sh_cp <= 1'b0;
                bit_state <= 6'd22;
            end
            6'd22:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd23;
            end
            6'd23:
            begin
                ds <= r_data[4];
                sh_cp <= 1'b0;
                bit_state <= 6'd24;
            end
            6'd24:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd25;
            end
            6'd25:
            begin
                ds <= r_data[3];
                sh_cp <= 1'b0;
                bit_state <= 6'd26;
            end
            6'd26:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd27;
            end
            6'd27:
            begin
                ds <= r_data[2];
                sh_cp <= 1'b0;
                bit_state <= 6'd28;
            end
            6'd28:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd29;
            end
            6'd29:
            begin
                ds <= r_data[1];
                sh_cp <= 1'b0;
                bit_state <= 6'd30;
            end
            6'd30:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd31;
            end
            6'd31:
            begin
                ds <= r_data[0];
                sh_cp <= 1'b0;
                bit_state <= 6'd32;
            end
            6'd32:
            begin
                sh_cp <= 1'b1;
                bit_state <= 6'd33;
            end
            6'd33:
            begin
                sh_cp <= 1'b0;
                st_cp <= 1'b1;
                bit_state <= 6'd34;
            end
            6'd34:
            begin
                st_cp <= 1'b0;
                bit_state <= 6'd0;
            end
            default:
                bit_state <= 6'd0;
        endcase
    end
end
endmodule