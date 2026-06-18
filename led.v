module Led_Toggle_Project(
    input i_Clk,
    input i_Switch_1,
    output o_Led_1
);
    reg r_Led_1 = 1'b0;
    reg r_Switch_1 = 1'b0;
    always @(posedge i_Clk)
    begin     
        r_Switch_1 <= i_Switch_1;
        if(i_Switch_1 == 1'b0 && r_Switch_1 == 1'b1)
            begin       
                r_Led_1 <= ~r_Led_1;
            end
    end
    assign o_Led_1 = r_Led_1;
endmodule