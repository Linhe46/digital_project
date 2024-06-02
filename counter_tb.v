`timescale 1ns/1ps
module counter_tb;
reg clk;
reg rstn;
wire[19:0] out_time;
wire[1:0]hou_h=out_time[19:18];
wire[3:0]hou_l=out_time[17:14];
wire[2:0]min_h=out_time[13:11];
wire[3:0]min_l=out_time[10:7];
wire[2:0]sec_h=out_time[6:4];
wire[3:0]sec_l=out_time[3:0];

counter mycounter(
    .clk(clk),
    .rstn(rstn),
    .out_time(out_time)
);

initial begin
    clk=0;
    rstn=1;
    #0.5 rstn=0;
    #0.5 rstn=1;
    #(86500*60) $finish;
end

always begin
    #2 clk=~clk;
end

endmodule