module Driver_7SD (
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
    localparam CHAR_R = 8'b0000_1000;
    localparam CHAR_L = 8'b1100_0111; 
    localparam CHAR_O = 8'b1100_0000; 
    localparam CHAR_S = 8'b1001_0010; 
    localparam BLANK  = 8'b1111_1111; 

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

    reg [7:0] w_Text_Arr [0:39];
    integer i;
    always @(*) begin
        for (i = 0; i < 40; i = i + 1) w_Text_Arr[i] = BLANK;
        
        if (i_Game_State == 3'd6) begin      
            w_Text_Arr[16] = CHAR_W; w_Text_Arr[17] = CHAR_I;
            w_Text_Arr[18] = CHAR_N; w_Text_Arr[19] = CHAR_N;
            w_Text_Arr[20] = CHAR_E; w_Text_Arr[21] = CHAR_R;
        end else if (i_Game_State == 3'd5) begin 
            w_Text_Arr[16] = CHAR_L; w_Text_Arr[17] = CHAR_O;
            w_Text_Arr[18] = CHAR_S; w_Text_Arr[19] = CHAR_E;
            w_Text_Arr[20] = CHAR_R;
        end
    end

    reg [23:0] r_Scroll_Timer = 0;
    reg [4:0]  r_Scroll_Index = 0; 

    always @(posedge i_Clk) begin
        if (r_Scroll_Timer >= 24'd7_500_000) begin
            r_Scroll_Timer <= 0;
            r_Scroll_Index <= r_Scroll_Index + 1; 
        end else begin
            r_Scroll_Timer <= r_Scroll_Timer + 1;
        end
    end

    reg [7:0] r_Msg_Buffer [0:7];
    integer k;
    always @(*) begin
        if (i_Game_State == 3'd6 || i_Game_State == 3'd5) begin
            for (k = 0; k < 8; k = k + 1) begin
                r_Msg_Buffer[k] = w_Text_Arr[(31 - r_Scroll_Index) + (7 - k)];
            end
        end else begin
            r_Msg_Buffer[7] = BLANK; r_Msg_Buffer[6] = BLANK;
            r_Msg_Buffer[5] = BLANK; r_Msg_Buffer[4] = BLANK;
            r_Msg_Buffer[3] = BLANK; r_Msg_Buffer[2] = BLANK;
            r_Msg_Buffer[1] = BLANK; r_Msg_Buffer[0] = r_Score_Seg; 
        end
    end
    reg [7:0]  r_Clk_Div = 0;
    reg [4:0]  r_Bit_Index = 0;
    reg [15:0] r_Shift_Reg_16 = 16'hFFFF;
    reg [2:0]  r_Digit_Idx = 0; 

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