module HammingIn (
    input logic [63:0] data_in,
    output logic [71:0] data_out,
    output logic resend
)
// Detect 2 error and correct 1 error
logic power[6:0];
assign power[0] = ^data_in[0:63];


endmodule
