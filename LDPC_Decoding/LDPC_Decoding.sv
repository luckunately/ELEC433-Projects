module LDPC_Decoding (
    input logic [71:0] data_in,
    output logic [63:0] data_out,
    input logic sendin, clk,
    output logic resend, ready
);
// The tanner check nodes:
logic [7:0] tanner;
// Each of them is connected to 18 data bits.
always_comb begin
    // 0 1 2 3 4 5 6 7 8 9 10 11 29 47 65 66 67 68, total of 18 bits
    tanner[0] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[29] ^ data_in[47] ^ data_in[65] ^ data_in[66] ^ data_in[67] ^ data_in[68];
    // 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 69, total of 18 bits
    tanner[1] = data_in[12] ^ data_in[13] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[69];
    // 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 70, total of 18 bits
    tanner[2] = data_in[30] ^ data_in[31] ^ data_in[32] ^ data_in[33] ^ data_in[34] ^ data_in[35] ^ data_in[36] ^ data_in[37] ^ data_in[38] ^ data_in[39] ^ data_in[40] ^ data_in[41] ^ data_in[42] ^ data_in[43] ^ data_in[44] ^ data_in[45] ^ data_in[46] ^ data_in[70];
    // 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 71, total of 18 bits
    tanner[3] = data_in[48] ^ data_in[49] ^ data_in[50] ^ data_in[51] ^ data_in[52] ^ data_in[53] ^ data_in[54] ^ data_in[55] ^ data_in[56] ^ data_in[57] ^ data_in[58] ^ data_in[59] ^ data_in[60] ^ data_in[61] ^ data_in[62] ^ data_in[63] ^ data_in[64] ^ data_in[71];
    // 1 5 7 14 18 28 29 30 31 33 35 40 47 48 56 59 63 65, total of 18 bits
    tanner[4] = data_in[1] ^ data_in[5] ^ data_in[7] ^ data_in[14] ^ data_in[18] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31] ^ data_in[33] ^ data_in[35] ^ data_in[40] ^ data_in[47] ^ data_in[48] ^ data_in[56] ^ data_in[59] ^ data_in[63] ^ data_in[65];
    // 0 4 8 11 15 21 24 26 41 43 45 49 53 58 60 61 67 69, total of 18 bits
    tanner[5] = data_in[0] ^ data_in[4] ^ data_in[8] ^ data_in[11] ^ data_in[15] ^ data_in[21] ^ data_in[24] ^ data_in[26] ^ data_in[41] ^ data_in[43] ^ data_in[45] ^ data_in[49] ^ data_in[53] ^ data_in[58] ^ data_in[60] ^ data_in[61] ^ data_in[67] ^ data_in[69];
    // 3 6 10 12 16 20 22 27 32 36 68 42 44 52 54 57 64 68, total of 18 bits
    tanner[6] = data_in[3] ^ data_in[6] ^ data_in[10] ^ data_in[12] ^ data_in[16] ^ data_in[20] ^ data_in[22] ^ data_in[27] ^ data_in[32] ^ data_in[36] ^ data_in[68] ^ data_in[42] ^ data_in[44] ^ data_in[52] ^ data_in[54] ^ data_in[57] ^ data_in[64] ^ data_in[68];
    // 2 9 13 17 19 23 25 34 37 39 46 50 51 55 62 66 70 71, total of 18 bits
    tanner[7] = data_in[2] ^ data_in[9] ^ data_in[13] ^ data_in[17] ^ data_in[19] ^ data_in[23] ^ data_in[25] ^ data_in[34] ^ data_in[37] ^ data_in[39] ^ data_in[46] ^ data_in[50] ^ data_in[51] ^ data_in[55] ^ data_in[62] ^ data_in[66] ^ data_in[70] ^ data_in[71];
end
// Now need to decode using majority voting: 
// Iterate at most 4 times for now

logic [1:0] count;
logic parity_L;
assign parity_L = |tanner; // Check if all the parity bits are 0, if so, then the data is correct
enum logic [3:0] {
    IDEL, 
    Check,
    Happy,
    Correction,
    done,
    notGood
} state, next_state;



logic [71:0] in_process;
always_ff @(posedge clk ) begin
    state <= next_state;
    case (state) 
        IDEL: begin
            count <= 4'b0;
        end
        Check: begin
            in_process <= data_in;
        end
        Happy: begin
            
        end
        Correction: begin
            count <= count + 1;
            if (tanner[0] & tanner[5]) begin
                // 0 4 8 11 67
                in_process[0] <= ~in_process[0];
                in_process[4] <= ~in_process[4];
                in_process[8] <= ~in_process[8];
                in_process[11] <= ~in_process[11];
                in_process[67] <= ~in_process[67];
            end
            if (tanner[0] & tanner[4]) begin
                // 1 5 7 29 47 65
                in_process[1] <= ~in_process[1];
                in_process[5] <= ~in_process[5];
                in_process[7] <= ~in_process[7];
                in_process[29] <= ~in_process[29];
                in_process[47] <= ~in_process[47];
                in_process[65] <= ~in_process[65];
            end
            if (tanner[0] & tanner[6]) begin
                // 3 6 10 68
                in_process[3] <= ~in_process[3];
                in_process[6] <= ~in_process[6];
                in_process[10] <= ~in_process[10];
                in_process[68] <= ~in_process[68];
            end
            if (tanner[0] & tanner[7]) begin
                // 2 9 66
                in_process[2] <= ~in_process[2];
                in_process[9] <= ~in_process[9];
                in_process[66] <= ~in_process[66];
            end
            if (tanner[1] & tanner[5]) begin
                // 15 21 24 26 69
                in_process[15] <= ~in_process[15];
                in_process[21] <= ~in_process[21];
                in_process[24] <= ~in_process[24];
                in_process[26] <= ~in_process[26];
                in_process[69] <= ~in_process[69];
            end
            if (tanner[1] & tanner[6])begin
                // 12 16 20 22 27
                in_process[12] <= ~in_process[12];
                in_process[16] <= ~in_process[16];
                in_process[20] <= ~in_process[20];
                in_process[22] <= ~in_process[22];
                in_process[27] <= ~in_process[27];
            end
            if (tanner[1] & tanner[7]) begin
                // 13 17 19 23 25
                in_process[13] <= ~in_process[13];
                in_process[17] <= ~in_process[17];
                in_process[19] <= ~in_process[19];
                in_process[23] <= ~in_process[23];
                in_process[25] <= ~in_process[25];
            end
            if (tanner[1] & tanner[4])begin
                // 14 18 28
                in_process[14] <= ~in_process[14];
                in_process[18] <= ~in_process[18];
                in_process[28] <= ~in_process[28];
            end
            if (tanner[2] & tanner[5]) begin
                // 41 43 45 
                in_process[41] <= ~in_process[41];
                in_process[43] <= ~in_process[43];
                in_process[45] <= ~in_process[45];
            end
            if (tanner[2] & tanner[6]) begin
                // 32 36 38 42 44
                in_process[32] <= ~in_process[32];
                in_process[36] <= ~in_process[36];
                in_process[38] <= ~in_process[38];
                in_process[42] <= ~in_process[42];
                in_process[44] <= ~in_process[44];
            end
            if (tanner[2] & tanner[7]) begin
                // 34 37 39 46 70
                in_process[34] <= ~in_process[34];
                in_process[37] <= ~in_process[37];
                in_process[39] <= ~in_process[39];
                in_process[46] <= ~in_process[46];
                in_process[70] <= ~in_process[70];
            end
            if (tanner[2] & tanner[4]) begin
                // 30 31 33 35 40
                in_process[30] <= ~in_process[30];
                in_process[31] <= ~in_process[31];
                in_process[33] <= ~in_process[33];
                in_process[35] <= ~in_process[35];
                in_process[40] <= ~in_process[40];
            end
            if (tanner[3] & tanner[5]) begin
                // 49 53 58 60 61
                in_process[49] <= ~in_process[49];
                in_process[53] <= ~in_process[53];
                in_process[58] <= ~in_process[58];
                in_process[60] <= ~in_process[60];
                in_process[61] <= ~in_process[61];
            end
            if (tanner[3] & tanner[6]) begin
                // 52 54 57 64
                in_process[52] <= ~in_process[52];
                in_process[54] <= ~in_process[54];
                in_process[57] <= ~in_process[57];
                in_process[64] <= ~in_process[64];
            end
            if (tanner[3] & tanner[7]) begin
                // 50 51 55 62 71
                in_process[50] <= ~in_process[50];
                in_process[51] <= ~in_process[51];
                in_process[55] <= ~in_process[55];
                in_process[62] <= ~in_process[62];
                in_process[71] <= ~in_process[71];
            end
            if (tanner[3] & tanner[4]) begin
                // 48, 56 59 63
                in_process[48] <= ~in_process[48];
                in_process[56] <= ~in_process[56];
                in_process[59] <= ~in_process[59];
                in_process[63] <= ~in_process[63];
            end
        end
        done: begin

        end
        notGood: begin

        end
    endcase
end

always_comb begin
    ready = 0;
    resend = 0;
    data_out = in_process;
    case (state) 
        IDEL: begin
            if (sendin) begin
                next_state = Check;
            end
            else begin
                next_state = IDEL;
            end
        end
        Check: begin
            if (parity_L) begin
                next_state = Correction;
            end
            else if (count == 0) begin
                next_state = notGood;
            end
            else begin
                next_state = Happy;
            end
        end
        Happy: begin
            next_state = done;
        end
        Correction: begin
            next_state = Check;
        end
        done: begin
            ready = 1;
            next_state = IDEL;
        end
        notGood: begin 
            resend = 1;
            if (~sendin)
            next_state = IDEL;
            else 
            next_state = notGood;
        end
        default: begin 
            next_state = IDEL;
        end
    endcase
end

endmodule