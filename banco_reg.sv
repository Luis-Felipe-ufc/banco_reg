`timescale 1ns/10ps
module banco_reg #(
    parameter DataWidth = 8,
    parameter NumRegs = 8
) (
    input logic clk,        // Clock
    input logic reset,      // Reset assíncrono
    input logic [7:0] wd3,  // Entrada de dados
    input logic [2:0] wa3,  // Seleção do registrador
    input logic we3,        // Habilita gravação de dados
    input logic [2:0] ra1,  // Seleção de qual registrador será disponibilizado na saída rd1
    input logic [2:0] ra2,  // Seleção de qual registrador será disponibilizado na saída rd2
    output logic [7:0] rd1,  // Barramento 1 de saída de 8 bits
    output logic [7:0] rd2  // Barramento 2 de saída de 8 bits
);

    // Registradores de 8 bits
    logic [DataWidth-1:0] regs[NumRegs];

    assign regs[0] = 0;
    assign rd1 = regs[ra1];
    assign rd2 = regs[ra2];

    always_ff @(posedge clk) begin      
        if (we3) begin
            if (wa3 != 0) begin
            regs[wa3] <= wd3;
            end else begin
                regs[0] <= regs[0];
            end
        end
    end

    always_ff @(negedge reset) begin
        if (!reset) begin
            regs <= '{default: '0};
        end
    end
    

endmodule
