module counter(
    input clk_sys,
    input rstn,
    output [19:0] out_time
);

reg[1:0] hou_h;
reg[2:0] sec_h, min_h;
reg[3:0] sec_l, min_l, hou_l;
//�ӷ��ź�
wire add_hou_h;
wire add_hou_l;
wire add_min_h;
wire add_min_l;
wire add_sec_h;
wire add_sec_l;
//�ﵽ���ֵ
wire max_hou_h;
wire max_hou_l;
wire max_min_h;
wire max_min_l;
wire max_sec_h;
wire max_sec_l;

//��ϵͳʱ�ӷ�ƵΪ1Hz
counter_div mycounterdiv(
    .clk(clk_sys),
    .rstn(rstn),
    .clk_div(clk)
);

//���λ

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

assign add_sec_l=1;
assign max_sec_l=(sec_l==4'b1001);

//���λ
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

assign max_sec_h=(sec_h==3'b101);
assign add_sec_h=max_sec_l;

//�ֵ�λ
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

assign add_min_l=(max_sec_h&&max_sec_l);
assign max_min_l=(min_l==4'b1001);

//�ָ�λ
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

assign add_min_h=(max_min_l&&max_sec_h&&max_sec_l);
assign max_min_h=(min_h==3'b101);

//ʱ��λ
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

assign add_hou_l=(max_min_h&&max_min_l&&max_sec_h&&max_sec_l);
assign max_hou_l=(hou_l==4'b1001||hou_l==4'b0011&&hou_h==2'b10);

//ʱ��λ
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

assign add_hou_h=(max_hou_l&&max_min_h&&max_min_l&&max_sec_h&&max_sec_l);
assign max_hou_h=(hou_h==2'b10);

assign out_time={hou_h,hou_l,min_h,min_l,sec_h,sec_l};

endmodule