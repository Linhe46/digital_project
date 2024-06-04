module top(
    input clk_sys,//系统时钟
    input rstn,
    input[4:0] button_in,
    output[6:0] led0,
    output[6:0] led1,
    output[3:0] led_mux0,
    output[3:0] led_mux1,
    output dp0,
    output dp1
);

localparam mid = 2, up= 4, left= 3,right =0 , down= 1;
localparam MID = 5'b00100, UP= 5'b10000, LEFT= 5'b01000, RIGHT= 5'b00001, DOWN= 5'b00010, NONE= 5'b00000;
parameter 
IDLE = 3'b000, 
SET = 3'b001, 
ALARM = 3'b010, 
COUNT = 3'b011, 
SELECT = 3'b100,

FIRST = 3'B000,
LAST = 3'B001;

wire clk;
wire[4:0] button;
//不同功能的时钟
wire[19:0] out_time;
wire[19:0] idle_time;
//reg[19:0] idle_time;
reg[19:0] set_time, count_time, alarm_time;
reg[2:0] state, next_state;

//将系统时钟分频为1Hz
counter_div mycounter_div(
    .clk(clk_sys),
    .rstn(rstn),
    .clk_div(clk)
);

//产生按键控制信号，由下跳沿触发
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

/*计时部分*/
reg[1:0] hou_h;
reg[2:0] sec_h, min_h;
reg[3:0] sec_l, min_l, hou_l;
//位加法信号
wire add_hou_h, add_hou_l, add_min_h, add_min_l, add_sec_h, add_sec_l;
//位达到最大值
wire max_hou_h, max_hou_l, max_min_h, max_min_l, max_sec_h, max_sec_l;

//秒低位
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
assign add_sec=(state!=SET);//非调时均计时
assign max_sec_l=(sec_l==4'b1001);
//秒高位
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
assign max_sec_h=(sec_h==3'b101);
assign add_sec_h=max_sec_l;
//分低位
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
assign add_min_l=(max_sec_h&&max_sec_l);
assign max_min_l=(min_l==4'b1001);
//分高位
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
assign add_min_h=(max_min_l&&max_sec_h&&max_sec_l);
assign max_min_h=(min_h==3'b101);
//时低位
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
assign add_hou_l=(max_min_h&&max_min_l&&max_sec_h&&max_sec_l);
assign max_hou_l=(hou_l==4'b1001||hou_l==4'b0011&&hou_h==2'b10);
//时高位
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
assign add_hou_h=(max_hou_l&&max_min_h&&max_min_l&&max_sec_h&&max_sec_l);
assign max_hou_h=(hou_h==2'b10);

assign idle_time={hou_h,hou_l,min_h,min_l,sec_h,sec_l};

/*调时部分*/

//状态转移
always @(posedge clk or negedge rstn)begin
    if(!rstn)begin
        state<=IDLE;
        //select_state<=IDLE; 多驱动错误
    end
    else begin
        state<=next_state;
        //select_state<=(next_state==SELECT ? select_state : next_state );多驱动
    end
end

//保存当前状态
reg[2:0] select_state;
always @(posedge clk or negedge rstn)begin
    if(!rstn)begin
        select_state<=IDLE;
    end
    else if(state==SELECT)begin
        if(button[left])
            select_state<=(select_state==FIRST ? LAST : select_state-1);
        else if(button[right])
            select_state<=(select_state==LAST ? FIRST : select_state+1);
    end
    else select_state<=state;
end



always @(*)begin
    case(state)
        SELECT:begin
            if(button[mid])
                next_state=select_state;
            /*
            else if(button[left])
                select_state=(select_state==FIRST ? LAST : select_state-1);
            else if(button[right])
                select_state=(select_state==LAST ? FIRST : select_state+1);
            */
            else
                next_state=SELECT;
        end
        SET:next_state=(button==MID ? IDLE : SET);
        default: next_state=(button[mid] ? SELECT : state);//任意状态只有按下mid进入选择
    endcase
end

reg[2:0] set_bit;//调时的位,0-5
always @(posedge clk or negedge rstn)begin
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
                    5:set_time[19:18]<=(set_time[19:18]==2'b10 ? 0 :set_time[19:18]+1);
                endcase
            end
            DOWN:begin
                case(set_bit)
                    0:set_time[3:0]<=(set_time[3:0]==4'b0000 ? 9 :set_time[3:0]-1);
                    1:set_time[6:4]<=(set_time[6:4]==3'b000 ? 5 :set_time[6:4]-1);
                    2:set_time[10:7]<=(set_time[10:7]==4'b0000 ? 0 : set_time[10:7]-1);
                    3:set_time[13:11]<=(set_time[13:11]==3'b000 ? 0 :set_time[13:11]-1);
                    4:set_time[17:14]<=(set_time[17:14]==4'b0000 ? (set_time[19:18]==2'b10 ? 3 : 9) : set_time[17:14]-1);
                    5:set_time[19:18]<=(set_time[19:18]==2'b00 ? (set_time[17:14]>3 ? 1 : 2) :set_time[19:18]-1);
                endcase
            end
            MID:set_time<=idle_time;
        endcase
    end
    else begin
        set_time<=idle_time;//跟随时钟变化
        set_bit<=0;
    end
end

assign out_time=(state==SET ? set_time : idle_time);

//数码管驱动
seg_on my_set_on(
    .clk_sys(clk_sys),
    .rstn(rstn),
    .time_data(out_time),
    .led0(led0),
    .led1(led1),
    .led_mux0(led_mux0),
    .led_mux1(led_mux1),
    .dp0(dp0),
    .dp1(dp1)
);


endmodule