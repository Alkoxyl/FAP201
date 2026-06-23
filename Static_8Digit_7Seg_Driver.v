module Static_8Digit_7Seg_Driver (
    input wire i_Clk,
    input wire [2:0] i_Game_State,
    input wire [3:0] i_Score,
    output reg o_DIO,
    output reg o_SCLK,
    output reg o_RCLK
);

    localparam CHAR_W = 8'b1100_0001; 
    localparam CHAR_I = 8'b1111_1001; 
    localparam CHAR_N = 8'b1010_1011; 
    localparam CHAR_E = 8'b1000_0110; 
    localparam CHAR_R = 8'b1010_1111; 
    localparam CHAR_L = 8'b1100_0111; 
    localparam CHAR_O = 8'b1100_0000; 
    localparam CHAR_S = 8'b1001_0010; 
    localparam BLANK  = 8'b1111_1111; 
    
    // --- Decode Điểm số (0-9) ---
    reg [7:0] r_Score_Seg;
    always @(*) begin
        case (i_Score)
            4'h0: r_Score_Seg = 8'b1100_0000;
            4'h1: r_Score_Seg = 8'b1111_1001;
            4'h2: r_Score_Seg = 8'b1010_0100;
            4'h3: r_Score_Seg = 8'b1011_0000;
            4'h4: r_Score_Seg = 8'b1001_1001;
            4'h5: r_Score_Seg = 8'b1001_0010;
            4'h6: r_Score_Seg = 8'b1000_0010;
            4'h7: r_Score_Seg = 8'b1111_1000;
            4'h8: r_Score_Seg = 8'b1000_0000;
            4'h9: r_Score_Seg = 8'b1001_0000;
            default: r_Score_Seg = BLANK;
        endcase
    end

    // --- Gán tĩnh chữ vào 8 LED (ĐÃ ĐẢO CHIỀU TỪ TRÁI SANG PHẢI) ---
    reg [7:0] r_Msg_Buffer [0:7];
    always @(*) begin
        if (i_Game_State == 3'd6) begin      
            // Trạng thái WINNER: Quét từ Trái (Index 7) sang Phải (Index 0)
            r_Msg_Buffer[7] = BLANK;
            r_Msg_Buffer[6] = CHAR_W;
            r_Msg_Buffer[5] = CHAR_I;
            r_Msg_Buffer[4] = CHAR_N;
            r_Msg_Buffer[3] = CHAR_N;
            r_Msg_Buffer[2] = CHAR_E;
            r_Msg_Buffer[1] = CHAR_R;
            r_Msg_Buffer[0] = BLANK;
        end else if (i_Game_State == 3'd5) begin 
            // Trạng thái LOSER: Quét từ Trái (Index 7) sang Phải (Index 0)
            r_Msg_Buffer[7] = BLANK;
            r_Msg_Buffer[6] = BLANK;
            r_Msg_Buffer[5] = CHAR_L;
            r_Msg_Buffer[4] = CHAR_O;
            r_Msg_Buffer[3] = CHAR_S;
            r_Msg_Buffer[2] = CHAR_E;
            r_Msg_Buffer[1] = CHAR_R;
            r_Msg_Buffer[0] = BLANK;
        end else begin
            // Trạng thái BÌNH THƯỜNG: Hiện điểm ở con LED cuối cùng bên phải (Index 0)
            r_Msg_Buffer[7] = BLANK;
            r_Msg_Buffer[6] = BLANK;
            r_Msg_Buffer[5] = BLANK;
            r_Msg_Buffer[4] = BLANK;
            r_Msg_Buffer[3] = BLANK;
            r_Msg_Buffer[2] = BLANK;
            r_Msg_Buffer[1] = BLANK;
            r_Msg_Buffer[0] = r_Score_Seg; 
        end
    end

    // --- Khối quét 8 LED ---
    reg [7:0]  r_Clk_Div = 0;
    reg [4:0]  r_Bit_Index = 0;
    reg [15:0] r_Shift_Reg_16 = 16'hFFFF;
    reg [2:0]  r_Digit_Idx = 0; 

    // Chân chọn LED: Active High (1 là bật)
    wire [7:0] w_Digit_Select = (8'b0000_0001 << r_Digit_Idx);

    always @(posedge i_Clk) begin
        r_Clk_Div <= r_Clk_Div + 1;
        
        if (r_Clk_Div == 8'd0) begin
            if (r_Bit_Index < 16) begin
                o_SCLK <= 0;
                o_RCLK <= 0;
                o_DIO  <= r_Shift_Reg_16[15]; 
                r_Bit_Index <= r_Bit_Index + 1;
            end 
            else if (r_Bit_Index == 16) begin
                o_RCLK <= 1; 
                r_Bit_Index <= r_Bit_Index + 1;
            end 
            else begin
                o_RCLK <= 0;
                r_Bit_Index <= 0;
                
                if (r_Digit_Idx < 7) 
                    r_Digit_Idx <= r_Digit_Idx + 1;
                else 
                    r_Digit_Idx <= 0;
                
                r_Shift_Reg_16 <= {r_Msg_Buffer[r_Digit_Idx], w_Digit_Select};
            end
        end 
        else if (r_Clk_Div == 8'd128) begin
            if (r_Bit_Index > 0 && r_Bit_Index <= 16) begin
                o_SCLK <= 1;
                r_Shift_Reg_16 <= {r_Shift_Reg_16[14:0], 1'b0};
            end
        end
    end
endmodule