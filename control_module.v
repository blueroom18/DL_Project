`timescale 1ns / 1ps

/*
special state: clean_state= 1010010 ; exit from storm= 1011101
control module

*/
module control_module(
    input [6:0] state,
    input sign_pos_A,
    input sign_pos_S,
    input sign_pos_W,
    input sign_pos_X,
    input sign_pos_D,
    input clk,
    output reg [31:0] sign,
    output reg [6:0] nxt_state
    );
    parameter [6:0] SHUTDOWN=7'b0000000,STANDBY=7'b1000000,MENU=7'b1010000,ONE=7'b1010100,TWO=7'b1011000,THREE=7'b1011100,EXIT_STROM=7'b1011101,CLEAN=7'1010010,
        SEARCH=7'b1010000,SEARCH_WORKTIME=7'b1100100,SEARCH_SWITCH_TIME=7'b1101000,SEARCH_REMINDTIME=7'b1101100,
        SET_SWI_HOUR=7'b1111001,SET_SWI_MIN=7'b1111010,SET_SWI_SEC=7'b1111011,SET_REMIND_HOUR=7'b1111101,SET_REMIND_MIN=7'b1111110,SET_REMIND_SEC=7'b1111111;
    
    reg [23:0]nowtime,worktime,remindtime,switchtime;
    reg storm_on; //only one time for storm
    reg [2:0]buttom_effect; //S,A,D
    
    always @(posedge clk) begin
        
    end


    always @(posedge sign_pos_S) begin
        case(state)
            SHUTDOWN:begin
                buttom_effect[2]<=1'b1;
            end
            STANDBY:begin
                buttom_effect[2]<=1'b1;
            end
            MENU:begin
                nxt_state <= TWO;
            end
            ONE:begin
                nxt_state <= TWO;
            end
            SEARCH:begin
                nxt_state <= SEARCH_SWITCH_TIME;
            end
            SET_REMIND_HOUR:begin
                nxt_state <= SET_REMIND_MIN;
            end
            SET_REMIND_MIN:begin
                nxt_state <= SET_REMIND_SEC;
            end
            SET_REMIND_SEC:begin
                nxt_state <= SEARCH_REMINDTIME;
            end
            SET_SWI_HOUR:begin
                nxt_state <= SET_SWI_MIN;
            end
            SET_SWI_MIN:begin
                nxt_state <= SET_SWI_SEC;
            end
            SET_SWI_SEC:begin
                nxt_state <= SEARCH_SWITCH_TIME;
            end
            default:; //do nothing
        endcase
    end

    always @(posedge sign_pos_W) begin
        case(state)
            STANDBY:begin
                nxt_state <= MENU;
            end
            MENU:begin
                nxt_state <= STANDBY;
            end
            ONE:BEGIN
                nxt_state <= STANDBY;
            end
            TWO:begin
                nxt_state <= STANDBY;
            end
            THREE:begin //exit
                nxt_state <= exit_storm;
                //to complete
            end
            SEARCH:begin
                nxt_state <= STANDBY;
            end
            SEARCH_WORKTIME:begin
                nxt_state <= SEARCH;
            end
            SEARCH_SWITCH_TIME:begin
                nxt_state <= SEARCH;
            end
            SEARCH_REMINDTIME:begin
                nxt_state <= SEARCH;
            end
        endcase
    end

    always @(posedge sign_pos_A) begin
        case(state)
            SHUTDOWN:begin
                //to complete
            end
            STANDBY:begin
                //to complete
            end
            MENU:begin
                nxt_state <= ONE;
            end
            TWO:begin
                nxt_state <= TWO;
            end
            SEARCH:begin
                nxt_state <= SEARCH_WORKTIME;
            end
            SET_REMIND_HOUR:begin
                if(remindtime[23:16] == 8'b00100011) begin  //23+1=0
                    remindtime[23:16] <= 8'b00000000;
                end
                else if(remindtime[19:16]==4'b1001) begin
                    remindtime[19:16] <= 4'b0000;
                    remindtime[23:16] <= remindtime[23:16]+1;
                end
                else remindtime[19:16] <= remindtime[19:16]+1;
            end
            SET_REMIND_MIN:begin
                if(remindtime[15:8] == 8'b01011001) begin   //59+1=0
                    remindtime[15:8] <= 8'b00000000;
                end
                else if(remindtime[11:8]==4'b1001) begin
                    remindtime[11:8] <= 4'b0000;
                    remindtime[15:8] <= remindtime[15:8]+1;
                end
                else remindtime[11:8] <= remindtime[11:8]+1;
            end
            SET_REMIND_SEC:begin
                if(remindtime[7:0] == 8'b01011001) begin
                    remindtime[7:0] <= 8'b00000000;
                end
                else if(remindtime[3:0]==4'b1001) begin
                    remindtime[3:0] <= 4'b0000;
                    remindtime[7:0] <= remindtime[7:0]+1;
                end
                else remindtime[3:0] <= remindtime[3:0]+1;
            end
            SET_SWI_HOUR:begin
                if(switchtime[23:16]==8'b00100011) begin
                    switchtime[23:16] <= 8'b00000000;
                end
                else if(switchtime[19:16]==4'b1001) begin
                    switchtime[19:16] <= 4'b0000;
                    switchtime[23:16] <= switchtime[23:16]+1;
                end
                else switchtime[19:16] <= switchtime[19:16]+1;
            end
            SET_SWI_MIN:begin
                if(switchtime[15:8]==8'b01011001) begin
                    switchtime[15:8] <= 8'b00000000;
                end
                else if(switchtime[11:8]==4'b1001) begin
                    switchtime[11:8] <= 4'b0000;
                    switchtime[15:8] <= switchtime[15:8]+1;
                end
                else switchtime[11:8] <= switchtime[11:8]+1;
            end
            SET_SWI_SEC:begin
                if(switchtime[7:0]==8'b01011001) begin
                    switchtime[7:0] <= 8'b00000000;
                end
                else if(switchtime[3:0]==4'b1001) begin
                    switchtime[3:0] <= 4'b0000;
                    switchtime[7:0] <= switchtime[7:0]+1;
                end
                else switchtime[3:0] <= switchtime[3:0]+1;
            end
            default:; //do nothing
        endcase
    end

    always @(posedge sign_pos_X) begin
        case(state)
            STANDBY:begin
                nxt_state <= SEARCH;
            end
            MENU:begin
                nxt_state <= clean_state;
            end
            SEARCH_SWITCH_TIME:begin
                nxt_state <= SET_SWI_HOUR;
            end
            SEARCH_REMINDTIME:begin
                nxt_state <= SET_REMIND_HOUR;
            end
            default:; //do nothing
        endcase
    end

    always @(posedge sign_pos_D) begin
        case(state)
            SHUTDOWN:begin
                //to complete
            end
            STANDBY:begin
                //to complete
            end
            MENU:begin
                //to complete
                if() begin
                 nxt_state <= THREE;
                end
            end
            SEARCH:begin
                nxt_state <= SEARCH_REMINDTIME;
            end
            default:; //do nothing
        endcase
    end
endmodule