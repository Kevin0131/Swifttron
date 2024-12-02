module tb_I_SOFTMAX();

  // input
  reg [31:0] q_in_soft;
  reg [31:0] q_b;
  reg [31:0] q_c;
  reg [31:0] q_ln2;
  reg [31:0] q_ln2_neg_inv;
  reg CLK;
  reg RST_n;
  reg EN_max;
  reg EN_acc;

  // output
  wire [31:0] q_out_soft;

  
  reg [31:0] test_data [0:9];  

  always #5 CLK = ~CLK;  // 10 ns


  I_SOFTMAX uut (
    .q_in_soft(q_in_soft),
    .q_b(q_b),
    .q_c(q_c),
    .q_ln2(q_ln2),
    .q_ln2_neg_inv(q_ln2_neg_inv),
    .CLK(CLK),
    .RST_n(RST_n),
    .EN_max(EN_max),
    .EN_acc(EN_acc),
    .q_out_soft(q_out_soft)
  );

  
  

  integer i;

  initial begin
    // testcase
    test_data[0] = 32'd10;  
    test_data[1] = 32'd20;  
    test_data[2] = 32'd30;  
    test_data[3] = -32'd10; 
    test_data[4] = 32'h7FFFFFFF; 
    test_data[5] = 32'd40;
    test_data[6] = 32'd50;
    test_data[7] = -32'd20;
    test_data[8] = 32'd60;
    test_data[9] = 32'd70;  

    
    CLK = 0;
    RST_n = 0;
    q_b = 32'd1;
    q_c = 32'd1;
    q_ln2 = 32'd32;       
    q_ln2_neg_inv = 32'd64;
    EN_max = 0;
    EN_acc = 0;

    
    #15 RST_n = 1;
    
    #15 RST_n = 0;  

    
    for (i = 0; i < 10; i = i + 1) begin
      #10 q_in_soft = test_data[i];  
          EN_max = 1;                
          EN_acc = 0;
          
      #10 EN_max = 0;                
          EN_acc = 1;                

      #20; 
    end

    
    #50 $finish;
  end

  
  initial begin
    $monitor("at %0t sec: q_in_soft = %d, q_out_soft = %d, EN_max = %b, EN_acc = %b", $time, q_in_soft, q_out_soft, EN_max, EN_acc);
  end

endmodule
