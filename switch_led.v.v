module switch_led(
    input sw1,
    input sw2,
    input sw3,
    output l1,
    output l2,
    output l3
);
    assign l1 = sw1;
    assign l2 = sw2; 
    assign l3 = sw3;
endmodule