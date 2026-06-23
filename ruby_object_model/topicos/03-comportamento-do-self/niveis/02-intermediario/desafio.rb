class Configurador
  def definir_ambiente_interno
    self.log_interno
  end

  def definir_ambiente_externo
    log_interno
  end

  private

  def log_interno
    "Log interno: #{self}"
  end
end

class ConfiguradorPersonalizado < Configurador
  def definir_ambiente_interno_pai
    self.log_interno
  end

  def definir_ambiente_externo_pai
    log_interno
  end
end

configurador = Configurador.new

# Chamada de método com self explícito. O método privado log_interno foi chamado normalmente
puts configurador.definir_ambiente_interno

# Chamada de método sem uso do self. O método privado log_interno foi chamado normalmente
puts configurador.definir_ambiente_externo

configurador_personalizado = ConfiguradorPersonalizado.new

# Chamada de método da super classe com self explícito. O método privado log_interno foi chamado normalmente
puts configurador_personalizado.definir_ambiente_interno

# Chamada de método da super classe sem uso do self. O método privado log_interno foi chamado normalmente
puts configurador_personalizado.definir_ambiente_externo

# Chamada de método da classe filho que chama método publico da classe pai e depois o privado com self explícito.
# O método privado log_interno foi chamado normalmente
puts configurador_personalizado.definir_ambiente_interno_pai

# Chamada de método da classe filho que chama método publico da classe pai e depois o privado sem uso do self.
# O método privado log_interno foi chamado normalmente
puts configurador_personalizado.definir_ambiente_externo_pai


=begin

Qual era a regra antiga?

Antigamente, a definição estrita de um método private em Ruby era: "Um método que nunca, sob circunstância alguma, pode
ser chamado com um receptor explícito (um objeto antes do ponto)". A única exceção histórica eram os métodos setters
(como self.status = "Ativo"), por uma necessidade de sintaxe para não confundir o Ruby com variáveis locais.

O que mudou no Ruby 2.7 e se consolidou no 3.x?

A comunidade percebeu que essa restrição gerava códigos redundantes ou dificultava refatorações quando queríamos deixar
claro que o método pertencia ao self. A regra foi atualizada para: "Métodos privados não podem ser chamados com um
receptor explícito, a menos que esse receptor seja especificamente a palavra-chave self".

=end