class Calculadora
  attr_reader :resultado

  def initialize(valor_inicial = nil)
    @resultado = valor_inicial
  end

  def self.sobre
    self
  end

  def somar(fator)
    @resultado ||= 0
    @resultado += fator
    self
  end
end

calculadora = Calculadora.new
calculadora.somar(5).somar(10).somar(-1)
puts "Resultado da soma: #{calculadora.resultado}"
puts "Sobre: #{Calculadora.sobre}"
