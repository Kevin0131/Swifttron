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
    reg [31:0] q_exp;
    reg [31:0] acc, q_out_tmp;
    reg sgn_z;  
    wire sgn_out;
    reg [3:0] flag,flag2;

    // Internal signals for I_EXP
    reg [31:32] q_p, z, z_tmp, zq_ln2;
    reg [63:0] zq_ln2_tmp;
    reg [31:0] q_l;

    // Internal signals for I_POLY_exp
    reg [63:0] square;
    reg [31:0] square_32;
    reg [31:0] sum_qb;
    reg [31:0] q_out_reg;

    
    always @(*) begin
        // *** I_POLY_exp logic ***
        // sum_qb = q + q_b
        sum_qb = $signed(q_p) + $signed(q_b);
        
        
        square = $signed(sum_qb) * $signed(q_p);
        
        
        square_32 = square[31:0]; 
        
       
        q_l = $signed(square_32) + $signed(q_c);

        // *** I_EXP logic ***
        // Calculate the sign of z
        sgn_z = q_diff[31] ^ q_ln2_neg_inv[31];

        
        z_tmp = $unsigned($signed(q_diff)) / $unsigned($signed(q_ln2_neg_inv));

        
        z = (sgn_z == 1'b0) ? z_tmp : -$signed(z_tmp);

        
        zq_ln2_tmp = $signed(z) * $signed(q_ln2);
        
        
        zq_ln2 = zq_ln2_tmp[31:0]; // Assuming bits_choice is 0

        
        q_p = $signed(q_diff) + $signed(zq_ln2);

        // Perform the shift operation
        if ($signed(z) > 0) begin
            q_out_reg = $signed(q_l) >>> $unsigned(z);
        end else begin
            q_out_reg = $signed(q_l) <<< $unsigned(-$signed(z));
        end

        q_exp = q_out_reg; 
    end

    always @(posedge CLK or negedge RST_n) begin
        if (RST_n!=0) begin
            q_max <= 32'b0;
            acc <= 32'b0;
            flag <= 4'b0011;
            flag2 <= 4'b0001;
        end else begin
            if (EN_max) begin
                if ($signed(q_in_soft) > $signed(q_max)) begin
                    q_max <= q_in_soft;
                    flag <= flag+1'b1;
                end
            end
            if (EN_acc) begin
                flag <= flag+1;
                acc <= $signed(acc) + $signed(q_exp);
                flag2 <= flag2 +1;
            end
        end
    end

    always @(*) begin
        q_diff = $signed(q_in_soft) - $signed(q_max);
    end

    // Calculate the output
    assign sgn_out = q_exp[31] ^ acc[31];

    always @(*) begin
        q_out_tmp = $unsigned($signed(q_exp) * $signed(acc));
        /* if(sgn_out==1'b0) q_out_soft = q_out_tmp;
        else q_out_soft = -$signed(q_out_tmp); */

        q_out_soft = (sgn_out == 1'b0) ? q_out_tmp : -$signed(q_out_tmp);
    end

endmodule

