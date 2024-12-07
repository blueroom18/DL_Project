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
    output [7:0]tub,
    output [7:0]seg_74,
    output [7:0]seg_30
);
    wire sign_pos_A, sign_pos_S,sign_neg_S,sign_pos_W, sign_pos_X, sign_pos_D;
    wire light_on;
    wire [3:0] sign7, sign6, sign5, sign4, sign3, sign2, sign1, sign0;
    wire [3:0] chip_74, chip_30;
    wire [7:0] seg_74, seg_30;
    wire [7:0] tub
    wire [6:0]nxt_state;
    reg [6:0]state;

    //light module
    assign light_on = light_dip & state[6];

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

    //control module
    control_module control_module(
        .state(state),
        .sign_pos_A(sign_pos_A),
        .sign_pos_S(sign_pos_S),
        .sign_pos_W(sign_pos_W),
        .sign_pos_X(sign_pos_X),
        .sign_pos_D(sign_pos_D),
        .nxt_state(nxt_state)
    );

    always @(nxt_state) begin
        state <= nxt_state;
    end
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
    reg [2:0] trig_A, trig_S, trig_W, trig_X, trig_D;
    always @(posedge clk,negedge buttom_rst) begin
        if(!buttom_rst) begin
            trig_A <= 3'b000;
            trig_S <= 3'b000;
            trig_W <= 3'b000;
            trig_X <= 3'b000;
            trig_D <= 3'b000;
        end
        else begin
            trig_A <= {trig_A[1:0],buttom_A};
            trig_S <= {trig_S[1:0],buttom_S};
            trig_W <= {trig_W[1:0],buttom_W};
            trig_X <= {trig_X[1:0],buttom_X};
            trig_D <= {trig_D[1:0],buttom_D};
        end
    end
    assign sign_pos_A = (~trig_A[2])&trig_A[1];
    assign sign_pos_S = (~trig_S[2])&trig_S[1];
    assign sign_neg_S = trig_S[2]&(~trig_S[1]);
    assign sign_pos_W = (~trig_W[2])&trig_W[1];
    assign sign_pos_X = (~trig_X[2])&trig_X[1];
    assign sign_pos_D = (~trig_D[2])&trig_D[1];
endmodule


/*
ouput module with [3:0]sign7-0, 7segment display
*/
module print_output(
    input light_on,
    input [3:0] sign7,
    input [3:0] sign6,
    input [3:0] sign5,
    input [3:0] sign4,
    input [3:0] sign3,
    input [3:0] sign2,
    input [3:0] sign1,
    input [3:0] sign0,
    input clk,
    output light_on_,
    output [3:0] chip_74,
    output [7:0] seg_74,
    output [3:0] chip_30,
    output [3:0] seg_30,
);
    parameter [7:0]num0=8'b;
    assign light_on_ = light_on;
    
endmodule

