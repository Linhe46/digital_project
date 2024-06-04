/*秒表分频模块*/
module timing_div(
    input clk_sys,
    input rstn,
    output reg clk_timing
);
localparam div_num= 1_0000_0000/200; //分频为100Hz(0.01s),19位

reg[18:0] cnt;
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        cnt<=0;
    else if(cnt != div_num)
        cnt<=cnt+1;
    else
        cnt<=0; 
end

always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        clk_timing<=0;
    else if(cnt==div_num)
        clk_timing<=~clk_timing;
    else
        clk_timing<=clk_timing;
end

endmodule;