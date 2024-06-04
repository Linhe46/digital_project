//信号消抖
module debounce(
    input clk,
    input rstn,
    input button_in,
    output reg button_out
);
    reg button_reg;
    reg[16:0]counter;
    always@(posedge clk or negedge rstn)begin
        if(!rstn)
            counter<=0;
        else if(button_reg != button_in|| |counter)
            counter<=counter+1;
        else
            counter<=0;
    end
    always@(posedge clk or negedge rstn)begin
        if(!rstn)
            button_out<=0;
        else if(|counter)
            button_out<=button_out;
        else
            button_out<=button_reg;
    end
    always@(posedge clk or negedge rstn)begin
        if(!rstn)
            button_reg<=0;
        else if(|counter)
            button_reg<=button_reg;
        else
            button_reg<=button_in;
    end
endmodule