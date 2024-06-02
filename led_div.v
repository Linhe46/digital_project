module led_div(
    input clk,
    input rstn,
    output led_clk
);
localparam div_num=15;

reg[div_num-1:0]clk_reg;
assign led_clk=clk_reg[div_num-1];

always @(posedge clk or negedge rstn)begin
    if(!rstn)
        clk_reg<=0;
    else
        clk_reg<=clk_reg+1;
end

endmodule