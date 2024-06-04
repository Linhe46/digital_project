//��ⰴ���źţ����ɹ�����-�ͷ�ʱ������һ������
module button_detect(
    input clk_sys,
    input rstn,
    input button_in,
    output button_out
);

localparam OFF=0, PRESS=1, ON=2;
wire signal;
reg[1:0] state, next_state;

//��������
debounce my_button_debounce(
    .clk(clk_sys),
    .rstn(rstn),
    .button_in(button_in),
    .button_out(signal)
);

always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        state<=OFF;
    else
        state<=next_state;
end

always @(*)begin
    case(state)
        OFF:next_state=(signal==1'b1 ? PRESS : OFF);
        PRESS:next_state=(signal==1'b0 ? ON : PRESS);
        ON:next_state=OFF;
    endcase
end

assign button_out=state==ON;

endmodule