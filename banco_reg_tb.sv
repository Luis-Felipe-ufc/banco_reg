`timescale 1ns/10ps
module banco_reg_tb;
  logic [7:0] wd3, rd1, rd2;
  logic [2:0] wa3, ra1, ra2;
  logic clk, reset, we3;
  
  // instantiating the module to map connections
  banco_reg regb(.clk(clk), .reset(reset), .wd3(wd3), .wa3(wa3), 
  .we3(we3), .ra1(ra1), .ra2(ra2), .rd1(rd1), .rd2(rd2)
  );
  
// Geração do clock
  initial clk = 0;
  always #5 clk = ~clk; // Clock com período de 10 ns

// initial begin
//   $display("\t\tTempo\twd3\twa3\tra1\trd1\tra2\trd2\treset");
// end

// initial $display("%t\t%d\t%b\t%b\t%d\t%b\t%d", $time, wd3, wa3, ra1, rd1, ra2, rd2);

// always #10 begin
//   $display("%t\t%b\t%b\t\t%d\t%b\t\t%d", $time, reset, ra1, rd1, ra2, rd2);
//   $display("%t\t%d\t%b\t%b\t%d\t%b\t%d\t%b", $time, wd3, wa3, ra1, rd1, ra2, rd2, reset);
// end

initial begin
  reset = 1;
  #1;
  reset = 0;
  #1;
  reset = 1;
end

// Procedimento de escrita
  // Alteração do dado
  initial begin
    we3 = 1;
    wd3 = 0;
    for (int i =0; i < 16; i++) begin
      wd3 = wd3 + 10;  
      #10;                    
    end
    // simu parou em 160ps

  end

  // Alteração do endereço
  initial begin
    for (int k = 0; k < 8; k++) begin
      wa3 = k;
      #20;
    end
  end

// Procedimento de leitura
  initial begin
    ra1 = 0;
    ra2 = 0;
    #20;
    ra1 = 1;
    ra2 = 1;
    #20;
    while (ra1 < 7) begin
      ra2 = ra1;
      ra1 = ra1 + 1;
      #20;                   
    end
    ra1 = 0;
    ra2 = 1;
    while (ra2 < 7) begin
      #10;
      ra1 = ra1 + 2;
      ra2 = ra2 + 2;                 
    end
    reset = 1;
    #5;
    reset = 0;
    #5;
    reset = 1;
    ra1 = 0;
    ra2 = 1;
    while (ra2 < 7) begin
      #10;
      ra1 = ra1 + 2;
      ra2 = ra2 + 2;                 
    end
    // simu parou em 160ps

    $finish();
  end

endmodule
