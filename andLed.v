module and_led(
    input switch_1, switch_2,
    output led_1);
    wire and_1;
    assign and_1 = switch_1 & switch_2;
    assign led_1 = and_1;
endmodule