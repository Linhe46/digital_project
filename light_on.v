module light_on(
    input clk_sys,
    input rstn,
    input reach_alarm,
    output [7:0]light
);
localparam
ALL_ON=8'b1111_1111,
ALL_OFF=8'b0000_0000,
MAX_COUNT=25'b11_1111_1111_1111_1111_1111_1111;

localparam
OFF=1,
ON1=2,
OFF1=3,
ON2=4,
OFF2=5,
ON3=6;


reg[2:0]state,next_state;
reg[25:0] counter;
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        counter<=0;
    else if(reach_alarm)
        counter<=counter+1;
    else if(|counter)
        counter<=counter+1;
    else
        counter<=0;
end

always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        state<=OFF;
    else
        state<=next_state;
end

always @(*)begin
    case(state)
        OFF:next_state=reach_alarm ? ON1 : OFF;
        ON1:next_state=counter==MAX_COUNT *1/5 ? OFF1 : ON1;
        OFF1:next_state=counter==MAX_COUNT*2/5 ? ON2 : OFF1;
        ON2:next_state=counter==MAX_COUNT *3/5 ? OFF2 : ON2;
        OFF2:next_state=counter==MAX_COUNT*4/5 ? ON3 : OFF2;
        ON3:next_state=counter==MAX_COUNT *5/5 ? OFF : ON3;
    endcase
end

assign light=(state==ON1||state==ON2||state==ON3 ? ALL_ON : ALL_OFF);
endmodule