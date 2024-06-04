module top(
    input clk_sys,//ϵͳʱ��
    input rstn,
    input[4:0] button_in,
    output[6:0] led0, led1,
    output[3:0] led_mux0, led_mux1,
    output dp0, dp1,
    output[7:0] light
);
//modified
parameter  MID = 5'b00100, UP= 5'b10000, LEFT= 5'b01000, RIGHT= 5'b00001, DOWN= 5'b00010, NONE= 5'b00000;
parameter 
IDLE = 3'b000, 
SET = 3'b001, 
ALARM = 3'b010, 
COUNT = 3'b011, 
SELECT = 3'b100,

FIRST = IDLE,
LAST = ALARM;

wire clk;//��ʱʱ��
wire[4:0] button;

wire[19:0] out_time;//���ʱ��

reg[19:0] idle_time, set_time, count_time, alarm_time;//��ʱ/��ʱ/���/����ʱ��

reg[2:0] state, next_state;//״̬

//��ϵͳʱ�ӷ�ƵΪ1Hz
counter_div mycounter_div(
    .clk(clk_sys),
    .rstn(rstn),
    .clk_div(clk)
);

//�������������źţ��������ش���
genvar i;
generate
    for(i=0;i<5;i=i+1) begin: detect
        button_detect S_i_detect(
            .clk_sys(clk_sys),
            .rstn(rstn),
            .button_in(button_in[i]),
            .button_out(button[i])
        );
    end
endgenerate

/*��ʱ��λ*/
reg[1:0] hou_h;
reg[2:0] sec_h, min_h;
reg[3:0] sec_l, min_l, hou_l;
//λ�ӷ��ź�
wire add_hou_h, add_hou_l, add_min_h, add_min_l, add_sec_h, add_sec_l;
//λ�ﵽ���ֵ
wire max_hou_h, max_hou_l, max_min_h, max_min_l, max_sec_h, max_sec_l;

//���λ
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        sec_l<=0;
    else if(state==SET) begin
        sec_l<=set_time[3:0];
    end
    else if(add_sec_l) begin
        if(max_sec_l)
            sec_l<=0;
        else
         sec_l<=sec_l+1;
    end
    else
        sec_l<=sec_l;
end
//assign add_sec_l=1;
assign add_sec_l= state==SET ? 0 : 1;//�ǵ�ʱ����ʱ
assign max_sec_l=(sec_l==4'b1001);
//���λ

always @(posedge clk or negedge rstn)begin
    if(!rstn)
        sec_h<=0;
    else if(state==SET) begin
        sec_h<=set_time[6:4];
    end
    else if(add_sec_h) begin
        if(max_sec_h)
            sec_h<=0;
        else
            sec_h<=sec_h+1;
    end
    else
        sec_h<=sec_h;
end
assign add_sec_h=max_sec_l&&add_sec_l;
assign max_sec_h=(sec_h==3'b101);

//�ֵ�λ
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        min_l<=0;
    else if(state==SET)
        min_l<=set_time[10:7];
    else if(add_min_l) begin
        if(max_min_l)
            min_l<=0;
        else
            min_l<=min_l+1;
    end
    else min_l<=min_l;
end
assign add_min_l=(max_sec_h&&add_sec_h);
assign max_min_l=(min_l==4'b1001);

//�ָ�λ
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        min_h<=0;
    else if(state==SET)
        min_h<=set_time[13:11];
    else if(add_min_h)begin
        if(max_min_h)
            min_h<=0;
        else
            min_h<=min_h+1; 
    end
    else min_h<=min_h;
end
assign add_min_h=(max_min_l&&add_min_l);
assign max_min_h=(min_h==3'b101);

//ʱ��λ
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        hou_l<=0;
    else if(state==SET)
        hou_l<=set_time[17:14];
    else if(add_hou_l)begin
        if(max_hou_l)
            hou_l<=0;
        else
            hou_l<=hou_l+1; 
    end
    else hou_l<=hou_l;
end
assign add_hou_l=(max_min_h&&add_min_h);
assign max_hou_l=(hou_l==4'b1001||hou_l==4'b0011&&hou_h==2'b10);

//ʱ��λ
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        hou_h<=0;
    else if(state==SET)
        hou_h<=set_time[19:18];
    else if(add_hou_h)begin
        if(max_hou_h)
            hou_h<=0;
        else
            hou_h<=hou_h+1; 
    end
    else hou_h<=hou_h;
end
assign add_hou_h=(max_hou_l&&add_hou_l);
assign max_hou_h=(hou_h==2'b10);


//ϵͳ״̬ת��
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        state<=IDLE;
    else
        state<=next_state;
end

//����ѡ�Ĭ��Ϊ��ǰ״̬
reg[2:0] select_state;
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)begin
        select_state<=IDLE;
    end
    else if(state==SELECT)begin
        if(button==LEFT)
            select_state<=(select_state==FIRST ? LAST : select_state-1);
        else if(button==RIGHT)
            select_state<=(select_state==LAST ? FIRST : select_state+1);
    end
    else select_state<=state;
end


always @(*)begin
    case(state)
        SELECT:begin
            if(button==MID)
                next_state=select_state;// ����ѡ��״̬
            else
                next_state=SELECT;
        end
        SET:next_state=(button==MID ? IDLE : SET);//SET ����mid�ص� IDLE
        ALARM:next_state=(button==MID ? IDLE : ALARM);
        default: next_state=(button==MID ? SELECT : state);//����mid����ѡ��
    endcase
end

/*��ʱ����*/
reg[2:0] set_bit;//��ʱ��λ,0-5
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)begin
        set_time<=0;
        set_bit<=0;
    end
    else if(state==SET)begin
        case(button)
            LEFT:set_bit<=(set_bit==5 ? 0 : set_bit+1);
            RIGHT:set_bit<=(set_bit==0 ? 5 :set_bit-1);
            UP:begin
                case(set_bit)
                    0:set_time[3:0]<=(set_time[3:0]==4'b1001 ? 0 :set_time[3:0]+1);
                    1:set_time[6:4]<=(set_time[6:4]==3'b101 ? 0 :set_time[6:4]+1);
                    2:set_time[10:7]<=(set_time[10:7]==4'b1001 ? 0 : set_time[10:7]+1);
                    3:set_time[13:11]<=(set_time[13:11]==3'b101 ? 0 :set_time[13:11]+1);
                    4:set_time[17:14]<=(set_time[17:14]==4'b1001 ? 0 :(set_time[17:14]==4'b0011&&set_time[19:18]==2'b10 ? 0 : set_time[17:14]+1));
                    5:set_time[19:18]<=(set_time[19:18]==2'b10 ? 0 : (set_time[19:18]==2'b01&&set_time[17:14]==4'b1001 ? 0 :set_time[19:18]+1));
                endcase
            end
            DOWN:begin
                case(set_bit)
                    0:set_time[3:0]<=(set_time[3:0]==4'b0000 ? 9 :set_time[3:0]-1);
                    1:set_time[6:4]<=(set_time[6:4]==3'b000 ? 5 :set_time[6:4]-1);
                    2:set_time[10:7]<=(set_time[10:7]==4'b0000 ? 9 : set_time[10:7]-1);
                    3:set_time[13:11]<=(set_time[13:11]==3'b000 ? 5 :set_time[13:11]-1);
                    4:set_time[17:14]<=(set_time[17:14]==4'b0000 ? (set_time[19:18]==2'b10 ? 3 : 9) : set_time[17:14]-1);
                    5:set_time[19:18]<=(set_time[19:18]==2'b00 ? (set_time[17:14]>3 ? 1 : 2) :set_time[19:18]-1);
                endcase
            end
            MID:set_time<=idle_time;
        endcase
    end
    else begin
        set_time<=idle_time;//����ʱ�ӱ仯
        set_bit<=0;
    end
end

always @(*)begin
    if(state==SET)
        idle_time=set_time;
    else
        idle_time={hou_h,hou_l,min_h,min_l,sec_h,sec_l};
end

/*���Ӳ���*/
reg has_alarm, reach_alarm, modify_alarm;
reg[2:0] alarm_bit;
always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)begin
        modify_alarm<=0;
        has_alarm<=0;
    end
    else if(state==ALARM)begin
        case(button)
            RIGHT:begin alarm_time<=0;modify_alarm<=0;end
            LEFT:alarm_bit<=(alarm_bit==5 ? 0 : alarm_bit+1);
            UP:begin
                //has_alarm<=1;
                modify_alarm<=1;
                case(alarm_bit)
                    0:alarm_time[3:0]<=(alarm_time[3:0]==4'b1001 ? 0 :alarm_time[3:0]+1);
                    1:alarm_time[6:4]<=(alarm_time[6:4]==3'b101 ? 0 :alarm_time[6:4]+1);
                    2:alarm_time[10:7]<=(alarm_time[10:7]==4'b1001 ? 0 : alarm_time[10:7]+1);
                    3:alarm_time[13:11]<=(alarm_time[13:11]==3'b101 ? 0 :alarm_time[13:11]+1);
                    4:alarm_time[17:14]<=(alarm_time[17:14]==4'b1001 ? 0 :(alarm_time[17:14]==4'b0011&&alarm_time[19:18]==2'b10 ? 0 : alarm_time[17:14]+1));
                    5:alarm_time[19:18]<=(alarm_time[19:18]==2'b10 ? 0 : (alarm_time[19:18]==2'b01&&alarm_time[17:14]==4'b1001 ? 0 :alarm_time[19:18]+1));
                endcase
            end
            DOWN:begin
                //has_alarm<=1;
                modify_alarm<=1;
                case(alarm_bit)
                    0:alarm_time[3:0]<=(alarm_time[3:0]==4'b0000 ? 9 :alarm_time[3:0]-1);
                    1:alarm_time[6:4]<=(alarm_time[6:4]==3'b000 ? 5 :alarm_time[6:4]-1);
                    2:alarm_time[10:7]<=(alarm_time[10:7]==4'b0000 ? 9 : alarm_time[10:7]-1);
                    3:alarm_time[13:11]<=(alarm_time[13:11]==3'b000 ? 5 :alarm_time[13:11]-1);
                    4:alarm_time[17:14]<=(alarm_time[17:14]==4'b0000 ? (alarm_time[19:18]==2'b10 ? 3 : 9) : alarm_time[17:14]-1);
                    5:alarm_time[19:18]<=(alarm_time[19:18]==2'b00 ? (alarm_time[17:14]>3 ? 1 : 2) :alarm_time[19:18]-1);
                endcase
            end
            MID:begin has_alarm<=(modify_alarm ? 1 :0); end
        endcase
    end
end

always @(posedge clk_sys or negedge rstn)begin
    if(!rstn)
        reach_alarm<=0;
    else if(alarm_time==idle_time&&has_alarm)//Ǳ�ڵ����⣺��ʱ�������ӣ�
        reach_alarm<=1;
    else
        reach_alarm<=0;
end

light_on my_light_on(
    .clk_sys(clk_sys),
    .rstn(rstn),
    .reach_alarm(reach_alarm),
    .light(light)
);


//assign out_time=(state==SET ? set_time : idle_time);
assign out_time=(state == SET ? set_time : (state == ALARM ? alarm_time : idle_time));



//״̬��Ϣ������λ��ʾ״̬������λ��ʾ��ǰѡ��(��SELECT)
wire[5:0] state_info;
assign state_info=(state==SELECT ? {select_state, state} : (state==ALARM ? {has_alarm, state} : IDLE));
//���������
seg_on my_set_on(
    .clk_sys(clk_sys),
    .rstn(rstn),
    .state_info(state_info),
    .time_data(out_time),
    .led0(led0),
    .led1(led1),
    .led_mux0(led_mux0),
    .led_mux1(led_mux1),
    .dp0(dp0),
    .dp1(dp1)
);

endmodule