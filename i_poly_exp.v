module I_POLY_exp #(
    parameter bits_choice = 0
)(
    input  [31:0] q, 
    input  [31:0] q_b, 
    input  [31:0] q_c,
    output [31:0] q_out
);

reg [63:0] square;
reg [31:0] square_32;
reg [31:0] sum_qb;
reg [31:0] q_out_reg;

assign q_out = q_out_reg;

always @(*) begin
    // sum_qb = q + q_b
    sum_qb = $signed(q) + $signed(q_b);
    
    // square = sum_qb * q
    square = $signed(sum_qb) * $signed(q);
    
    // square_32 = square(31+bits_choice downto bits_choice)
    square_32 = square[31+bits_choice:bits_choice];
    
    // q_out = square_32 + q_c
    q_out_reg = $signed(square_32) + $signed(q_c);
end

endmodule
