`timescale 1ns/1ps
module button_signal_tb;
reg clk;
reg rstn;
reg button_in;
wire button_out;

button_detect mysignal(
    .clk_sys(clk),
    .rstn(rstn),
    .button_in(button_in),
    .button_out(button_out)
);

initial begin
    clk=0;
    rstn=1;
    button_in=0;
    #2 rstn=0;
    #2 rstn=1;
    #2 button_in=1;
    #15 button_in=0;
    #200 $finish;
end

always begin
    #5 clk=~clk;
end

endmodule