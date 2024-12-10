`timescale 1ns / 1ps
module Main(
    input buttom_A,
    input buttom_S,
    input buttom_W,
    input buttom_X,
    input buttom_D,
    input buttom_rst,
    input clk,
    input light_dip,
    output light_on_,
    output [7:0]chip,
    output [7:0]seg_74,
    output [7:0]seg_30

    ,output sA,sS,sD,sW,sX
);
    wire sign_pos_A, sign_pos_S,sign_neg_S,sign_pos_W, sign_pos_X, sign_pos_D;
    wire [31:0] sign;
    wire [6:0]nxt_state;
    reg [6:0]state;

    //light module
    assign light_on_ = light_dip & state[6];

    //debounce module
    Edge_detection edge_detection(
        .buttom_A(buttom_A),
        .buttom_S(buttom_S),
        .buttom_W(buttom_W),
        .buttom_X(buttom_X),
        .buttom_D(buttom_D),
        .buttom_rst(buttom_rst),
        .clk(clk),
        .sign_pos_A(sign_pos_A),
        .sign_pos_S(sign_pos_S),
        .sign_neg_S(sign_neg_S),
        .sign_pos_W(sign_pos_W),
        .sign_pos_X(sign_pos_X),
        .sign_pos_D(sign_pos_D)
    );

    always @(negedge buttom_rst) begin
        state <= 7'b0000000;
    end

    always @(nxt_state) begin
        state <= nxt_state;
    end

    //control module
    control_module control_module(
        .state(state),
        .sign_pos_A(sign_pos_A),
        .sign_pos_S(sign_pos_S),
        .sign_neg_S(sign_neg_S),
        .sign_pos_W(sign_pos_W),
        .sign_pos_X(sign_pos_X),
        .sign_pos_D(sign_pos_D),
        .rst(buttom_rst),
        .clk(clk),
        .sign(sign),
        .nxt_state(nxt_state)
    );
    
    //output module
    print_output print(
        .en(state[6]),
        .sign7(sign[31:28]),
        .sign6(sign[27:24]),
        .sign5(sign[23:20]),
        .sign4(sign[19:16]),
        .sign3(sign[15:12]),
        .sign2(sign[11:8]),
        .sign1(sign[7:4]),
        .sign0(sign[3:0]),
        .rst(buttom_rst),
        .clk(clk),
        .seg_74(seg_74),
        .seg_30(seg_30),
        .tub_sel(chip)
    );

endmodule


/*
debounce module with inputs for buttons buttom_A, buttom_S, buttom_W, buttom_X, buttom_D, buttom_rst,clk
*/
module Edge_detection(
    input buttom_A,
    input buttom_S,
    input buttom_W,
    input buttom_X,
    input buttom_D,
    input buttom_rst,
    input clk,
    output sign_pos_A,
    output sign_pos_S,
    output sign_neg_S,
    output sign_pos_W,
    output sign_pos_X,
    output sign_pos_D
);
    reg [2:0]cnt;
    reg [3:0] trig_A, trig_S, trig_W, trig_X, trig_D;
    always @(posedge clk,negedge buttom_rst) begin
        if(!buttom_rst) begin
            trig_A <= 4'b0000;
            trig_S <= 4'b0000;
            trig_W <= 4'b0000;
            trig_X <= 4'b0000;
            trig_D <= 4'b0000;
            cnt <= 3'b000;
        end
        else begin
            cnt <= cnt + 3'b001;
            if(cnt == 3'b111) begin
                trig_A <= {trig_A[2:0],buttom_A};
                trig_S <= {trig_S[2:0],buttom_S};
                trig_W <= {trig_W[2:0],buttom_W};
                trig_X <= {trig_X[2:0],buttom_X};
                trig_D <= {trig_D[2:0],buttom_D};
            end
        end
    end
    assign sign_pos_A = (~trig_A[3])&(~trig_A[2])&trig_A[1];
    assign sign_pos_S = (~trig_S[3])&(~trig_S[2])&trig_S[1];
    assign sign_neg_S = (trig_S[3])&(trig_S[2])&(~trig_S[1]);
    assign sign_pos_W = (~trig_W[3])&(~trig_W[2])&trig_W[1];
    assign sign_pos_X = (~trig_X[3])&(~trig_X[2])&trig_X[1];
    assign sign_pos_D = (~trig_D[3])&(~trig_D[2])&trig_D[1];
endmodule