module I_EXP #(
    parameter bits_choice = 0
)(
    input [31:0] q_in_exp,
    input [31:0] q_b,
    input [31:0] q_c,
    input [31:0] q_ln2,
    input [31:0] q_ln2_neg_inv,
    output reg [31:0] q_out_exp
);

    reg [31:0] q_p, z, z_tmp, zq_ln2;
    reg [63:0] zq_ln2_tmp;
    reg [31:0] q_l;
    wire sgn_z;

    // Instantiate the I_POLY_exp module
    I_POLY_exp #(.bits_choice(bits_choice)) poly (
        .q(q_p),
        .q_b(q_b),
        .q_c(q_c),
        .q_out(q_l)
    );

    // Calculate the sign of z
    assign sgn_z = q_in_exp[31] ^ q_ln2_neg_inv[31];

    always @(*) begin
        // Calculate z_tmp using absolute values
        z_tmp = $unsigned($signed(q_in_exp)) / $unsigned($signed(q_ln2_neg_inv));

        // Adjust sign of z
        z = (sgn_z == 1'b0) ? z_tmp : -$signed(z_tmp);

        // Calculate zq_ln2_tmp
        zq_ln2_tmp = $signed(z) * $signed(q_ln2);
        
        // Select bits for zq_ln2 based on bits_choice
        zq_ln2 = zq_ln2_tmp[31+bits_choice : bits_choice];

        // Calculate q_p
        q_p = $signed(q_in_exp) + $signed(zq_ln2);
    end

    // Perform the shift operation
    always @(*) begin
        if ($signed(z) > 0) begin
            q_out_exp = $signed(q_l) >>> $unsigned(z);
        end else begin
            q_out_exp = $signed(q_l) <<< $unsigned(-$signed(z));
        end
    end

endmodule


module I_POLY_exp #(
    parameter bits_choice = 0
)(
    input [31:0] q,
    input [31:0] q_b,
    input [31:0] q_c,
    output [31:0] q_out
);
    // The logic of the I_POLY_exp module would be defined here
endmodule
