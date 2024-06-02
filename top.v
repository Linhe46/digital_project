module top(
    input clk_sys,//系统时钟
    input rstn,

    output[6:0] led0,
    output[6:0] led1,
    output[3:0] led_mux0,
    output[3:0] led_mux1,
    output dp0,
    output dp1
);
//wire clk;//模块时钟
wire[19:0] time_data;

counter mycounter(
    .clk_sys(clk_sys),
    .rstn(rstn),
    .out_time(time_data)
);

seg_on myseg_on(
    .clk_sys(clk_sys),
    .rstn(rstn),
    .time_data(time_data),
    .led0(led0),
    .led1(led1),
    .led_mux0(led_mux0),
    .led_mux1(led_mux1),
    .dp0(dp0),
    .dp1(dp1)
);

endmodule