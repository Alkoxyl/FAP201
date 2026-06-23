module State_Machine_Project_Top 
 (input i_Clk,
  input i_Switch_1,
  input i_Switch_2,
  input i_Switch_3,
  output o_LED_1,
  output o_LED_2,
  output o_LED_3,
  output o_SEG7_DIO,
  output o_SEG7_SCLK,
  output o_SEG7_RCLK);

  localparam GAME_LIMIT     = 5;        
  localparam CLKS_PER_SEC   = 50000000;
  localparam DEBOUNCE_LIMIT = 500000;

  wire w_Switch_1_Raw, w_Switch_2_Raw, w_Switch_3_Raw;
  wire w_Switch_1, w_Switch_2, w_Switch_3;
  wire w_LED_1, w_LED_2, w_LED_3;
  wire [3:0] w_Score;
  wire [2:0] w_Game_State; 

  Debounce_Filter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) Debounce_SW1 (.i_Clk(i_Clk), .i_Bouncy(i_Switch_1), .o_Debounced(w_Switch_1_Raw));
  Debounce_Filter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) Debounce_SW2 (.i_Clk(i_Clk), .i_Bouncy(i_Switch_2), .o_Debounced(w_Switch_2_Raw));
  Debounce_Filter #(.DEBOUNCE_LIMIT(DEBOUNCE_LIMIT)) Debounce_SW3 (.i_Clk(i_Clk), .i_Bouncy(i_Switch_3), .o_Debounced(w_Switch_3_Raw));

  assign w_Switch_1 = ~w_Switch_1_Raw;
  assign w_Switch_2 = ~w_Switch_2_Raw;
  assign w_Switch_3 = ~w_Switch_3_Raw;

  State_Machine_Game #(.CLKS_PER_SEC(CLKS_PER_SEC), .GAME_LIMIT(GAME_LIMIT)) Game_Inst
   (.i_Clk(i_Clk),
    .i_Switch_1(w_Switch_1),
    .i_Switch_2(w_Switch_2),
    .i_Switch_3(w_Switch_3),
    .o_Score(w_Score),
    .o_LED_1(w_LED_1),
    .o_LED_2(w_LED_2),
    .o_LED_3(w_LED_3),
    .o_Game_State(w_Game_State)); 

  assign o_LED_1 = ~w_LED_1;
  assign o_LED_2 = ~w_LED_2;
  assign o_LED_3 = ~w_LED_3;

  Driver_7SD Scoreboard
   (.i_Clk(i_Clk),
    .i_Game_State(w_Game_State),
    .i_Score(w_Score),
    .o_DIO(o_SEG7_DIO),
    .o_SCLK(o_SEG7_SCLK),
    .o_RCLK(o_SEG7_RCLK));

endmodule