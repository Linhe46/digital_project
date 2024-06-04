/*计时分频模块*/
module counter_div(
    input clk,
    input rstn,
    output reg clk_div
);
localparam div_num = 1_0000_0000/2;//分频为1Hz

reg[25:0] cnt;
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        cnt<=0;
    else if(cnt != div_num)
        cnt<=cnt+1;
    else
        cnt<=0;
end

always @(posedge clk or negedge rstn)begin
    if(!rstn)
        clk_div<=0;
    else if(cnt == div_num)
        clk_div<=~clk_div;
    else
        clk_div<=clk_div;
end

endmodule