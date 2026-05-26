# Nível: Intermediário
# Abertura da Singleton Class usando a sintaxe class << self para definir múltiplos métodos de classe.

class Configuration
  class << self
    attr_accessor :api_key
    
    def setup
      yield self
    end
  end
end

Configuration.setup do |config|
  config.api_key = "12345"
end

puts Configuration.api_key # => "12345"
