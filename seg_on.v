module seg_on(
    input clk_sys,
    input rstn,
    input[19:0] time_data,
    output reg[6:0]led0,
    output reg[6:0]led1,
    output reg[3:0]led_mux0,//0组，用于显示时
    output reg[3:0]led_mux1,//1组，用于显示分秒
    output reg dp0,
    output reg dp1
);

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
SEG_OFF=7'b0000000; 

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
    else if(led_mux0==4'b0001)
        led_mux0<=4'b0010;
    else
        led_mux0<=4'b0001;
end

//数码管显示逻辑
reg[3:0]num1;
always @(*)begin
    if(!rstn)
        num1=0;
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
        endcase
    end
end

reg[3:0]num0;
always @(*)begin
    if(!rstn)
        num0=0;
    else begin
    case(led_mux0)
        4'b0001:begin num0=time_data[17:14];dp0=1;end
        4'b0010:begin num0=time_data[19:18];dp0=0;end
    endcase
    end
end

always @(*)begin
    if(!rstn)
        led0=0;
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
        endcase
    end
end


endmodule