module I_SOFTMAX (
    input [31:0] q_in_soft,
    input [31:0] q_b,
    input [31:0] q_c,
    input [31:0] q_ln2,
    input [31:0] q_ln2_neg_inv,
    input CLK,
    input RST_n,
    input EN_max,
    input EN_acc,
    output reg [31:0] q_out_soft
);

    reg [31:0] q_max, q_diff;
    wire [31:0] q_exp;
    reg [31:0] acc, q_out_tmp;
    wire sgn_out;

    // Instantiate the I_EXP module
    I_EXP #(.bits_choice(0)) exp_unit (
        .q_in_exp(q_diff),
        .q_b(q_b),
        .q_c(q_c),
        .q_ln2(q_ln2),
        .q_ln2_neg_inv(q_ln2_neg_inv),
        .q_out_exp(q_exp)
    );

    always @(posedge CLK or negedge RST_n) begin
        if (!RST_n) begin
            q_max <= 32'b0;
            acc <= 32'b0;
        end else begin
            if (EN_max) begin
                if ($signed(q_in_soft) > $signed(q_max)) begin
                    q_max <= q_in_soft;
                end
            end
            if (EN_acc) begin
                acc <= $signed(acc) + $signed(q_exp);
            end
        end
    end

    always @(*) begin
        q_diff = $signed(q_in_soft) - $signed(q_max);
    end

    // Calculate the output
    assign sgn_out = q_exp[31] ^ acc[31];

    always @(*) begin
        q_out_tmp = $unsigned($signed(q_exp) / $signed(acc));
        q_out_soft = (sgn_out == 1'b0) ? q_out_tmp : -$signed(q_out_tmp);
    end

endmodule


module I_EXP #(
    parameter bits_choice = 0
)(
    input [31:0] q_in_exp,
    input [31:0] q_b,
    input [31:0] q_c,
    input [31:0] q_ln2,
    input [31:0] q_ln2_neg_inv,
    output [31:0] q_out_exp
);
    // The logic of the I_EXP module would be defined here
endmodule
