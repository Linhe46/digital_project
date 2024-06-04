module seg_on(
    input clk_sys,
    input rstn,
    input[5:0] state_info,
    input[19:0] time_data,
    output reg[6:0]led0,
    output reg[6:0]led1,
    output reg[3:0]led_mux0,//0组，用于显示时
    output reg[3:0]led_mux1,//1组，用于显示分秒
    output reg dp0,
    output reg dp1
);
localparam
IDLE = 3'b000, 
SET = 3'b001, 
ALARM = 3'b010, 
COUNT = 3'b011, 
SELECT = 3'b100;

localparam
SEG_0=7'b111_1110,
SEG_1=7'b011_0000,
SEG_2=7'b110_1101,
SEG_3=7'b111_1001,
SEG_4=7'b011_0011,
SEG_5=7'b101_1011,
SEG_6=7'b101_1111,
SEG_7=7'b111_0000,
SEG_8=7'b111_1111,
SEG_9=7'b111_1011,
SEG_OFF=7'b0000000,

SEG_S=7'b101_1011,
SEG_E=7'b100_1111,
SEG_L=7'b000_1110,
SEG_C=7'b100_1110,
SEG_T=7'b100_0110,

SEG_SLASH=7'b000_0001;

//分频用于循环显示
wire led_clk;
led_div myled_div(
    .clk(clk_sys),
    .rstn(rstn),
    .led_clk(led_clk)
);

//循环移位
always @(posedge led_clk or negedge rstn)begin
    if(!rstn)
        led_mux1<=4'b0001;
    else
        led_mux1<={led_mux1[2:0],led_mux1[3]};
end
always @(posedge led_clk or negedge rstn)begin
    if(!rstn)
        led_mux0<=4'b0001;
    else
        led_mux0<={led_mux0[2:0],led_mux0[3]};
end

//数码管显示数字逻辑,0-9表示数字,10-14表示五个字母,15表示熄灭
reg[3:0]num1;
always @(*)begin
    if(!rstn)begin
        num1=0;
        dp1=0;
    end
    else if(state_info[2:0]==SELECT)begin
        case(led_mux1)
            4'b0001:begin num1=14; dp1=0;end
            4'b0010:begin num1=13; dp1=0;end
            4'b0100:begin num1=11; dp1=0;end
            4'b1000:begin num1=12; dp1=0;end
    endcase
    end
    else begin
        case(led_mux1)
            4'b0001:begin num1=time_data[3:0];dp1=0;end
            4'b0010:begin num1=time_data[6:4];dp1=0;end
            4'b0100:begin num1=time_data[10:7];dp1=1;end
            4'b1000:begin num1=time_data[13:11];dp1=0;end
        endcase
    end
end

always @(*)begin
    if(!rstn)
        led1=0;
    else begin
        case(num1)
            0: led1=SEG_0;
            1: led1=SEG_1;
            2: led1=SEG_2;
            3: led1=SEG_3;
            4: led1=SEG_4;
            5: led1=SEG_5;
            6: led1=SEG_6;
            7: led1=SEG_7;
            8: led1=SEG_8;
            9: led1=SEG_9;
            10: led1=SEG_S;
            11: led1=SEG_E;
            12: led1=SEG_L;
            13: led1=SEG_C;
            14: led1=SEG_T;
            15: led1=SEG_OFF;
        endcase
    end
end


reg[3:0]num0;
always @(*)begin
    if(!rstn)begin
        num0=0;
        dp0=0;
    end
    else if(state_info[2:0]==SELECT)begin
        case(led_mux0)
        4'b0001:begin num0=11; dp0=0;end//E
        4'b0010:begin num0=10; dp0=0;end//S
        4'b0100:begin num0=15; dp0=0;end//OFF
        4'b1000:begin 
            case(state_info[5:3])  
                IDLE:num0=1;
                SET:num0=2;
                ALARM:num0=3;
                COUNT:num0=4;
            endcase
            dp0=0;end//STATE_NUMBER,1=IDLE,2=SET,3=ALARM,4=COUNT
    endcase
    end
    else begin
    case(led_mux0)
        4'b0001:begin num0=time_data[17:14];dp0=1;end
        4'b0010:begin num0=time_data[19:18];dp0=0;end
        default:begin num0=15;dp0=0;end
    endcase
    end
end

always @(*)begin
    if(!rstn)
        led0=SEG_OFF;
    else begin
        case(num0)
            0: led0=SEG_0;
            1: led0=SEG_1;
            2: led0=SEG_2;
            3: led0=SEG_3;
            4: led0=SEG_4;
            5: led0=SEG_5;
            6: led0=SEG_6;
            7: led0=SEG_7;
            8: led0=SEG_8;
            9: led0=SEG_9;
            10: led0=SEG_S;
            11: led0=SEG_E;
            12: led0=SEG_L;
            13: led0=SEG_C;
            14: led0=SEG_T;
            15: led0=SEG_OFF;
        endcase
    end
end


endmodule