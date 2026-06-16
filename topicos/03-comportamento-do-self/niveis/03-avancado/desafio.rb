class CaixaDeAreia < BasicObject
  def initialize(tipo, massa_maxima)
    @tipo = tipo || :fina
    @massa_maxima = massa_maxima || 100
    @massa_preenchida = 0
  end

  def colocar_areia(massa)
    @massa_preenchida += massa if @massa_preenchida + massa.to_i <= @massa_maxima
    self
  end

  def remover_areia(massa)
    if @massa_preenchida - massa.to_i >= 0
      @massa_preenchida -= massa 
    else
      @massa_preenchida = 0
    end

    self
  end

  def limpar_caixa
    @massa_preenchida = 0
    self
  end

  def atualizar_massa_maxima(massa)
    @massa_maxima = massa if massa.to_i >= @massa_preenchida
    self
  end

  def to_s
    "tipo: #{@tipo} - massa_preenchida: #{@massa_preenchida} - massa_maxima: #{@massa_maxima}"
  end

  private

  attr_accessor :tipo, :massa_maxima, :massa_preenchida
end

class ExecutorDeCaixaDeAreia
  def initialize(tipo, massa)
    @caixa_de_areia = CaixaDeAreia.new(tipo, massa)
  end

  def executar(&)
    caixa_de_areia.instance_exec(&)
    puts caixa_de_areia
    self
  end

  private

  attr_reader :caixa_de_areia
end

executor = ExecutorDeCaixaDeAreia.new(:fina, 100)

executor.executar do
  colocar_areia(52)
  remover_areia(17)
end

executor.executar do
  colocar_areia(10)
  remover_areia(5)
end

executor.executar { colocar_areia(1000) }
executor.executar { remover_areia(1000) }

executor.executar do
  atualizar_massa_maxima(1500)
  colocar_areia(1000)
end
