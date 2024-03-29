module Hamming72out (
    input logic [71:0] data_in,
    output logic [63:0] data_out,
    input logic sendin, clk,
    output logic resend, ready
);
// Put it into a matrix form for easier understanding
logic [7:0] matrix[8:0];
always_comb begin
    matrix[0] = data_in[7:0];
    matrix[1] = data_in[15:8];
    matrix[2] = data_in[23:16];
    matrix[3] = data_in[31:24];
    matrix[4] = data_in[39:32];
    matrix[5] = data_in[47:40];
    matrix[6] = data_in[55:48];
    matrix[7] = data_in[63:56];
    matrix[8] = data_in[71:64];
end
logic [6:0] parity;
logic total;
logic [71:0] processing;

assign total = ^data_in[71:1]; //Indicate if there is an error

always_comb begin
parity[0]= matrix[1][1]^matrix[2][1]^matrix[3][1]^matrix[4][1]^matrix[5][1]^matrix[6][1]^matrix[7][1]^matrix[8][1]
^matrix[0][3]^matrix[1][3]^matrix[2][3]^matrix[3][3]^matrix[4][3]^matrix[5][3]^matrix[6][3]^matrix[7][3]^matrix[8][3]
^matrix[0][5]^matrix[1][5]^matrix[2][5]^matrix[3][5]^matrix[4][5]^matrix[5][5]^matrix[6][5]^matrix[7][5]^matrix[8][5]
^matrix[0][7]^matrix[1][7]^matrix[2][7]^matrix[3][7]^matrix[4][7]^matrix[5][7]^matrix[6][7]^matrix[7][7]^matrix[8][7];

parity[1]= matrix[1][2]^matrix[2][2]^matrix[3][2]^matrix[4][2]^matrix[5][2]^matrix[6][2]^matrix[7][2]^matrix[8][2]
^matrix[0][3]^matrix[1][3]^matrix[2][3]^matrix[3][3]^matrix[4][3]^matrix[5][3]^matrix[6][3]^matrix[7][3]^matrix[8][3]
^matrix[0][6]^matrix[1][6]^matrix[2][6]^matrix[3][6]^matrix[4][6]^matrix[5][6]^matrix[6][6]^matrix[7][6]^matrix[8][6]
^matrix[0][7]^matrix[1][7]^matrix[2][7]^matrix[3][7]^matrix[4][7]^matrix[5][7]^matrix[6][7]^matrix[7][7]^matrix[8][7];

parity[2]= matrix[1][4]^matrix[2][4]^matrix[3][4]^matrix[4][4]^matrix[5][4]^matrix[6][4]^matrix[7][4]^matrix[8][4]
^matrix[0][5]^matrix[1][5]^matrix[2][5]^matrix[3][5]^matrix[4][5]^matrix[5][5]^matrix[6][5]^matrix[7][5]^matrix[8][5]
^matrix[0][6]^matrix[1][6]^matrix[2][6]^matrix[3][6]^matrix[4][6]^matrix[5][6]^matrix[6][6]^matrix[7][6]^matrix[8][6]
^matrix[0][7]^matrix[1][7]^matrix[2][7]^matrix[3][7]^matrix[4][7]^matrix[5][7]^matrix[6][7]^matrix[7][7]^matrix[8][7];

parity[3]= matrix[1][1]^matrix[1][2]^matrix[1][3]^matrix[1][4]^matrix[1][5]^matrix[1][6]^matrix[1][7]
^matrix[3][0]^matrix[3][1]^matrix[3][2]^matrix[3][3]^matrix[3][4]^matrix[3][5]^matrix[3][6]^matrix[3][7]
^matrix[5][0]^matrix[5][1]^matrix[5][2]^matrix[5][3]^matrix[5][4]^matrix[5][5]^matrix[5][6]^matrix[5][7]
^matrix[7][0]^matrix[7][1]^matrix[7][2]^matrix[7][3]^matrix[7][4]^matrix[7][5]^matrix[7][6]^matrix[7][7];

parity[4]= matrix[2][1]^matrix[2][2]^matrix[2][3]^matrix[2][4]^matrix[2][5]^matrix[2][6]^matrix[2][7]
^matrix[3][0]^matrix[3][1]^matrix[3][2]^matrix[3][3]^matrix[3][4]^matrix[3][5]^matrix[3][6]^matrix[3][7]
^matrix[6][0]^matrix[6][1]^matrix[6][2]^matrix[6][3]^matrix[6][4]^matrix[6][5]^matrix[6][6]^matrix[6][7]
^matrix[7][0]^matrix[7][1]^matrix[7][2]^matrix[7][3]^matrix[7][4]^matrix[7][5]^matrix[7][6]^matrix[7][7];

parity[5]= matrix[4][1]^matrix[4][2]^matrix[4][3]^matrix[4][4]^matrix[4][5]^matrix[4][6]^matrix[4][7]
^matrix[5][0]^matrix[5][1]^matrix[5][2]^matrix[5][3]^matrix[5][4]^matrix[5][5]^matrix[5][6]^matrix[5][7]
^matrix[6][0]^matrix[6][1]^matrix[6][2]^matrix[6][3]^matrix[6][4]^matrix[6][5]^matrix[6][6]^matrix[6][7]
^matrix[7][0]^matrix[7][1]^matrix[7][2]^matrix[7][3]^matrix[7][4]^matrix[7][5]^matrix[7][6]^matrix[7][7];

parity[6]= matrix[8][1]^matrix[8][2]^matrix[8][3]^matrix[8][4]^matrix[8][5]^matrix[8][6]^matrix[8][7];
end

enum logic [2:0] {
    Idel,
    comein,
    correct, // 1 bit error, correct it
    good,
    bad // 2 bit error, resend

} FSM;

logic [2:0] state, next_state;
logic parity_check;
logic errorPosition[6:0];

always_comb begin
    next_state = state;
    parity_check = ~(errorPosition[0]|errorPosition[1]|errorPosition[2]|errorPosition[3]|errorPosition[4]|errorPosition[5]|errorPosition[6]); // if there is an error, errorPosition will be non-zero
    resend = 0;
    errorPosition[0] = parity[0] ^ matrix[0][1];
    errorPosition[1] = parity[1] ^ matrix[0][2];
    errorPosition[2] = parity[2] ^ matrix[0][4];
    errorPosition[3] = parity[3] ^ matrix[1][0];
    errorPosition[4] = parity[4] ^ matrix[2][0];
    errorPosition[5] = parity[5] ^ matrix[4][0];
    errorPosition[6] = parity[6] ^ matrix[8][0];
    case (state)
        Idel: begin
            if (sendin) begin
                next_state = comein;
            end
        end
        comein: begin
            if (parity_check && (total == data_in[0])) begin
                // No error
                next_state = good;
            end
            else if (total != data_in[0]) begin
                // assume 1 bit error and correct it
                next_state = correct;
            end
            else begin
                // assume 2 bit error
                next_state = bad;
            end
        end
        correct: begin
            next_state = good;
        end
        good: begin
            if (sendin) begin
                next_state = comein;
            end
            else begin
                next_state = Idel;
            end
        end
        bad: begin
            if (sendin) begin
                next_state = comein;
            end
            else begin
                resend = 1;
                next_state = bad;
            end
        end
    endcase
end

always_ff @(posedge clk) begin
    state <= next_state;
    case(state)
        Idel: ready <= 0;
        comein: begin 
            ready <= 0;
            processing <= data_in; // store the data for processing
        end
        correct: begin 
            ready <= 0;
            case (errorPosition)
                7'h3: processing[3] <= ~processing[3];
                7'h5: processing[5] <= ~processing[5];
                7'h6: processing[6] <= ~processing[6];
                7'h7: processing[7] <= ~processing[7];
                7'h9: processing[9] <= ~processing[9];
                7'h10: processing[10] <= ~processing[10];
                7'h11: processing[11] <= ~processing[11];
                7'h12: processing[12] <= ~processing[12];
                7'h13: processing[13] <= ~processing[13];
                7'h14: processing[14] <= ~processing[14];
                7'h15: processing[15] <= ~processing[15];
                7'h17: processing[17] <= ~processing[17];
                7'h18: processing[18] <= ~processing[18];
                7'h19: processing[19] <= ~processing[19];
                7'h20: processing[20] <= ~processing[20];
                7'h21: processing[21] <= ~processing[21];
                7'h22: processing[22] <= ~processing[22];
                7'h23: processing[23] <= ~processing[23];
                7'h24: processing[24] <= ~processing[24];
                7'h25: processing[25] <= ~processing[25];
                7'h26: processing[26] <= ~processing[26];
                7'h27: processing[27] <= ~processing[27];
                7'h28: processing[28] <= ~processing[28];
                7'h29: processing[29] <= ~processing[29];
                7'h30: processing[30] <= ~processing[30];
                7'h31: processing[31] <= ~processing[31];
                7'h33: processing[33] <= ~processing[33];
                7'h34: processing[34] <= ~processing[34];
                7'h35: processing[35] <= ~processing[35];
                7'h36: processing[36] <= ~processing[36];
                7'h37: processing[37] <= ~processing[37];
                7'h38: processing[38] <= ~processing[38];
                7'h39: processing[39] <= ~processing[39];
                7'h40: processing[40] <= ~processing[40];
                7'h41: processing[41] <= ~processing[41];
                7'h42: processing[42] <= ~processing[42];
                7'h43: processing[43] <= ~processing[43];
                7'h44: processing[44] <= ~processing[44];
                7'h45: processing[45] <= ~processing[45];
                7'h46: processing[46] <= ~processing[46];
                7'h47: processing[47] <= ~processing[47];
                7'h48: processing[48] <= ~processing[48];
                7'h49: processing[49] <= ~processing[49];
                7'h50: processing[50] <= ~processing[50];
                7'h51: processing[51] <= ~processing[51];
                7'h52: processing[52] <= ~processing[52];
                7'h53: processing[53] <= ~processing[53];
                7'h54: processing[54] <= ~processing[54];
                7'h55: processing[55] <= ~processing[55];
                7'h56: processing[56] <= ~processing[56];
                7'h57: processing[57] <= ~processing[57];
                7'h58: processing[58] <= ~processing[58];
                7'h59: processing[59] <= ~processing[59];
                7'h60: processing[60] <= ~processing[60];
                7'h61: processing[61] <= ~processing[61];
                7'h62: processing[62] <= ~processing[62];
                7'h63: processing[63] <= ~processing[63];
                7'h65: processing[65] <= ~processing[65];
                7'h66: processing[66] <= ~processing[66];
                7'h67: processing[67] <= ~processing[67];
                7'h68: processing[68] <= ~processing[68];
                7'h69: processing[69] <= ~processing[69];
                7'h70: processing[70] <= ~processing[70];
                7'h71: processing[71] <= ~processing[71];
                default: begin 
                    // ignore the error on parity bit
                end
            endcase
        end
        good: ready <= 1; // no more action needed
        bad: begin 
            ready <= 0; // resend signal is handled by combinational logic to save register
        end
    endcase
end

always_comb begin
    data_out[0] = processing[3];
    data_out[1] = processing[5];
    data_out[2] = processing[6];
    data_out[3] = processing[7];
    data_out[4] = processing[9];
    data_out[5] = processing[10];
    data_out[6] = processing[11];
    data_out[7] = processing[12];
    data_out[8] = processing[13];
    data_out[9] = processing[14];
    data_out[10] = processing[15];
    data_out[11] = processing[17];
    data_out[12] = processing[18];
    data_out[13] = processing[19];
    data_out[14] = processing[20];
    data_out[15] = processing[21];
    data_out[16] = processing[22];
    data_out[17] = processing[23];
    data_out[18] = processing[24];
    data_out[19] = processing[25];
    data_out[20] = processing[26];
    data_out[21] = processing[27];
    data_out[22] = processing[28];
    data_out[23] = processing[29];
    data_out[24] = processing[30];
    data_out[25] = processing[31];
    data_out[26] = processing[33];
    data_out[27] = processing[34];
    data_out[28] = processing[35];
    data_out[29] = processing[36];
    data_out[30] = processing[37];
    data_out[31] = processing[38];
    data_out[32] = processing[39];
    data_out[33] = processing[40];
    data_out[34] = processing[41];
    data_out[35] = processing[42];
    data_out[36] = processing[43];
    data_out[37] = processing[44];
    data_out[38] = processing[45];
    data_out[39] = processing[46];
    data_out[40] = processing[47];
    data_out[41] = processing[48];
    data_out[42] = processing[49];
    data_out[43] = processing[50];
    data_out[44] = processing[51];
    data_out[45] = processing[52];
    data_out[46] = processing[53];
    data_out[47] = processing[54];
    data_out[48] = processing[55];
    data_out[49] = processing[56];
    data_out[50] = processing[57];
    data_out[51] = processing[58];
    data_out[52] = processing[59];
    data_out[53] = processing[60];
    data_out[54] = processing[61];
    data_out[55] = processing[62];
    data_out[56] = processing[63];
    data_out[57] = processing[65];
    data_out[58] = processing[66];
    data_out[59] = processing[67];
    data_out[60] = processing[68];
    data_out[61] = processing[69];
    data_out[62] = processing[70];
    data_out[63] = processing[71];
end

endmodule