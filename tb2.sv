`timescale 1ns/10ps

module tb_banco_reg;

    // Parâmetros do design
    parameter DataWidth = 8;
    parameter NumRegs = 8;

    // Sinais
    logic clk, reset;
    logic [DataWidth-1:0] wd3;
    logic [2:0] wa3, ra1, ra2;
    logic we3;
    logic [DataWidth-1:0] rd1, rd2;

    // Instância do DUT (Design Under Test)
    banco_reg #(
        .DataWidth(DataWidth),
        .NumRegs(NumRegs)
    ) dut (
        .clk(clk),
        .reset(reset),
        .wd3(wd3),
        .wa3(wa3),
        .we3(we3),
        .ra1(ra1),
        .ra2(ra2),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Geração de clock
    always #5 clk = ~clk;

    // Teste exaustivo
    initial begin
        // Inicialização
        clk = 0;
        reset = 0;
        wd3 = 0;
        wa3 = 0;
        ra1 = 0;
        ra2 = 0;
        we3 = 0;

        // Aplicar reset e verificar inicialização
        $display("Início do teste: Reset");
        reset = 1;
        #10;
        reset = 0;
        #10;
        assert(dut.regs == '{default: '0}) else $fatal("Falha no reset");

        // Testar escrita e leitura em cada registrador
        $display("Teste de gravação e leitura");
        for (int i = 1; i < NumRegs; i++) begin
            wd3 = i * 10;       // Valor de teste
            wa3 = i;            // Endereço do registrador
            we3 = 1;            // Habilitar escrita
            #10;                // Esperar para captura no clock
            we3 = 0;

            // Validar escrita
            assert(dut.regs[i] == wd3) else $fatal("Falha na escrita no registrador %0d", i);

            // Testar leitura
            ra1 = i;
            #10;                // Esperar para leitura
            assert(rd1 == wd3) else $fatal("Falha na leitura do registrador %0d", i);
        end

        // Testar que registrador 0 é imutável
        $display("Teste do registrador 0");
        wd3 = 123;
        wa3 = 0;
        we3 = 1;
        #10;
        we3 = 0;
        assert(dut.regs[0] == 0) else $fatal("Falha: registrador 0 foi alterado");

        // Testar combinações de leitura
        $display("Teste de combinações de leitura");
        for (int i = 0; i < NumRegs; i++) begin
            for (int j = 0; j < NumRegs; j++) begin
                ra1 = i;
                ra2 = j;
                #5;
                assert(rd1 == dut.regs[i]) else $fatal("Falha na saída rd1 para ra1=%0d", i);
                assert(rd2 == dut.regs[j]) else $fatal("Falha na saída rd2 para ra2=%0d", j);
            end
        end

        $display("Todos os testes passaram!");
        $finish;
    end
endmodule
