module counter(
    input clk_sys,
    input rstn,
    output [19:0] out_time
);

reg[1:0] hou_h;
reg[2:0] sec_h, min_h;
reg[3:0] sec_l, min_l, hou_l;
//位加法信号
wire add_hou_h;
wire add_hou_l;
wire add_min_h;
wire add_min_l;
wire add_sec_h;
wire add_sec_l;
//达到最大值
wire max_hou_h;
wire max_hou_l;
wire max_min_h;
wire max_min_l;
wire max_sec_h;
wire max_sec_l;

assign add_sec_l=1;
assign max_sec_l=(sec_l==4'b1001);

assign add_sec_h=max_sec_l&&add_sec_l;
assign max_sec_h=(sec_h==3'b101);

assign add_min_l=(max_sec_h&&add_sec_h);
assign max_min_l=(min_l==4'b1001);

assign add_min_h=(max_min_l&&add_min_l);
assign max_min_h=(min_h==3'b101);

assign add_hou_l=(max_min_h&&add_min_h);
assign max_hou_l=(hou_l==4'b1001||hou_l==4'b0011&&hou_h==2'b10);

assign add_hou_h=(max_hou_l&&add_hou_l);
assign max_hou_h=(hou_h==2'b10);


//将系统时钟分频为1Hz
counter_div mycounterdiv(
    .clk(clk_sys),
    .rstn(rstn),
    .clk_div(clk)
);

//秒低位
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        sec_l<=0;
    else if(add_sec_l) begin
        if(max_sec_l)
            sec_l<=0;
        else
         sec_l<=sec_l+1;
    end
    else
        sec_l<=sec_l+1;
end

//秒高位
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        sec_h<=0;
    else if(add_sec_h) begin
        if(max_sec_h)
            sec_h<=0;
        else
            sec_h<=sec_h+1;
    end
    else
        sec_h<=sec_h;
end

//分低位
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        min_l<=0;
    else if(add_min_l) begin
        if(max_min_l)
            min_l<=0;
        else
            min_l<=min_l+1;
    end
    else min_l<=min_l;
end

//分高位
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        min_h<=0;
    else if(add_min_h)begin
        if(max_min_h)
            min_h<=0;
        else
            min_h<=min_h+1; 
    end
    else min_h<=min_h;
end

//时低位
always @(posedge clk or negedge rstn)begin
    if(!rstn)
        hou_l<=0;
    else if(add_hou_l)begin
        if(max_hou_l)
            hou_l<=0;
        else
            hou_l<=hou_l+1; 
    end
    else hou_l<=hou_l;
end

//时高位
always @(posedge clk or negedge rstn) begin
    if(!rstn)
        hou_h<=0;
    else if(add_hou_h)begin
        if(max_hou_h)
            hou_h<=0;
        else
            hou_h<=hou_h+1; 
    end
    else hou_h<=hou_h;
end

assign out_time={hou_h,hou_l,min_h,min_l,sec_h,sec_l};

endmodule