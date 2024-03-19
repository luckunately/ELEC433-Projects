module HammingIn (
    input logic [71:0] data_in,
    output logic [63:0] data_out,
    input logic sendin, clk,
    output logic resend, ready
);
// Put it into a matrix form for easier understanding
logic matrix[0:8][0:7];
always_comb begin
    matrix[0][0:7]= data_in[0:7];
    matrix[1][0:7]= data_in[8:15];
    matrix[2][0:7]= data_in[16:23];
    matrix[3][0:7]= data_in[24:31];
    matrix[4][0:7]= data_in[32:39];
    matrix[5][0:7]= data_in[40:47];
    matrix[6][0:7]= data_in[48:55];
    matrix[7][0:7]= data_in[56:63];
    matrix[8][0:7]= data_in[64:71];
end
logic [6:0] parity;
logic total;

assign total = ^data_out[1:71]; //Indicate if there is an error

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



enum logic [2:0] {
    Idel,
    comein,
    correct, // 1 bit error, correct it
    good,
    bad, // 2 bit error, resend

}

logic [2:0] state, next_state;
logic parity_check;

always_comb begin
    next_state = state;
    parity_check = (parity[0] == matrix[0][1]) && (parity[1] == matrix[0][2]) && (parity[2] == matrix[0][4]) && (parity[3] == matrix[1][0]) && (parity[4] == matrix[2][0]) && (parity[5] == matrix[4][0]) && (parity[6] == matrix[8][0]);
    resend = 0;
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

always_ff (posedge clk) begin
    state <= next_state;
    case(state):
        Idel: ready <= 1;
        comein: ready <= 0;
        correct: ready <= 1;
        good: ready <= 1;
        bad: ready <= 0;
    endcase
end

endmodule