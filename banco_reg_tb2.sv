`timescale 1ns/10ps
module banco_reg_tb2;
  logic [7:0] wd3, rd1, rd2;
  logic [7:0] reg_anterior[8];
  logic [2:0] wa3, ra1, ra2;
  logic clk, reset, we3;
  int verif_count = 0;          // Conta quantas verificações
  
  // instantiating the module to map connections
  banco_reg dut(.clk(clk), .reset(reset), .wd3(wd3), .wa3(wa3), 
  .we3(we3), .ra1(ra1), .ra2(ra2), .rd1(rd1), .rd2(rd2)
  );

  // Propriedades
    property reg0_is_immutable;     // Checa se o reg 0 é sempre 0
        @(posedge clk) we3 |-> !wa3 |-> (wd3 != 0) |-> (dut.regs[0] == 0);
    endproperty

    property correct_reading;       // Checa se a leitura está correta
        @(ra1 or ra2) (rd1 == dut.regs[ra1]) && (rd2 == dut.regs[ra2]);
    endproperty

    property enable_off;     // Checa escrita desabilitada
        @(posedge clk) !we3 |-> (dut.regs[wa3] == reg_anterior[wa3]);
    endproperty

  // Executa um reset (padrão 1)
  task automatic generate_reset(input int duration);
    begin
      reset = 0;
      #duration;
      reset = 1; 
    end
  endtask

  // Cria um valor randomico a cada intervalo de tempo
  task automatic generate_rand(output logic [7:0] variavel, input int atraso);
    begin
      variavel = $urandom;
      #atraso;
    end
  endtask //automatic
  
// Geração do clock
  initial clk = 0;
  always #5 clk = ~clk; // Clock com período de 10 ns

  // Reset inicial
  initial begin
  generate_reset (1);
  // Verifica o funcionamento do reset
  assert (dut.regs == '{default: '0}) verif_count++; else $fatal;
  end

  always begin 
    generate_rand (wd3, 10);           // Cria valores aleatorios para wd3 a cada 10ns
    reg_anterior[wa3] = dut.regs[wa3]; // Salva o valor do registrador antes de sobrescrever
  end  
  always generate_rand (wa3, 20);      // Cria valores aleatorios para wd3 a cada 20ns
  always generate_rand (ra1, 20);      // Cria valores aleatorios para ra1 a cada 20ns
  always generate_rand (ra2, 20);      // Cria valores aleatorios para ra2 a cada 20ns

  initial begin
    we3 = 1;    // Habilita a escrita
    // Inicia os endereços em 0 e espera a atualização automática
    ra1 = 0;
    ra2 = 0;
    wa3 = 0;
    #1000;
    // Reseta os registradores de novo e testa
    generate_reset (1);
    assert(dut.regs == '{default: '0}) verif_count++; else $fatal;
    #1000;
    we3 = 0;  // Desabilita escrita
    #1000;
    we3 = 1;  // Habilita novamente
    #100ms;   // Duração da simulação para testar vários cenários
    $display("Simulação concluída sem erros! Foram feitas %0d verificações", verif_count);
    $finish();
  end

  // Faz verificações a cada ciclo de clock
  assert property(reg0_is_immutable) verif_count++; else $fatal;
  assert property(enable_off) verif_count++; else $fatal;

  // Faz verificações a cada mudança de endereço de leitura
  assert property(correct_reading) verif_count++; else $fatal;

  // Verifica a escrita a cada alteração do banco
  always @(dut.regs) begin
    if ((wa3 != 0) && reset) begin
    assert(dut.regs[wa3] == wd3) verif_count++; else $fatal;
    end
  end

endmodule
