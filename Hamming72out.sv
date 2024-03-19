module HammingIn (
    input logic [71:0] data_in,
    output logic [63:0] data_out,
    output logic resend
)
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

endmodule