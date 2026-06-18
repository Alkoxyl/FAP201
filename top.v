module Debounce_Project_Top(
    input i_Clk,
    input i_Switch_1,
    output o_Led_1
);
    wire w_Debounced_Switch;
    Debounce_Filter #(.DEBOUNCE_LIMIT(250000)) Debounce_Inst (
    .i_Clk(i_Clk),
    .i_Bouncy(i_Switch_1),
    .o_Debounced(w_Debounced_Switch)
);
Led_Toggle_Project Led_Toggle_Inst (
    .i_Clk(i_Clk),
    .i_Switch_1(w_Debounced_Switch),
    .o_Led_1(o_Led_1)
);
endmodule