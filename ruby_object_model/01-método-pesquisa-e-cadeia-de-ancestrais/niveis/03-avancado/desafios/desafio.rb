# Resposta do Gemini

# Implementar um sistema de hooks usando prepend dinâmico é uma excelente demonstração do poder do modelo de objetos do Ruby.
# Quando uma classe faz o prepend de um módulo, esse módulo é inserido antes da própria classe na cadeia de ancestralidade (ancestor chain). Isso significa que, se o módulo e a classe tiverem um método com o mesmo nome, o método do módulo é executado primeiro, e ele pode chamar o método da classe original usando super.
# Aqui está uma implementação elegante e direta desse sistema:

class BaseController
  # Este hook do Ruby é disparado sempre que uma classe herda de BaseController
  def self.inherited(subclass)
    super
    
    # Criamos um módulo anônimo e dinâmico exclusivamente para esta subclasse
    interceptor_module = Module.new
    
    # Injetamos o módulo na FRENTE da subclasse
    subclass.prepend(interceptor_module)
    
    # Guardamos uma referência guardada no escopo da classe para usar no before_action
    subclass.instance_variable_set(:@_interceptor_module, interceptor_module)
  end

  # Macro estilo Rails para declarar os callbacks
  def self.before_action(callback_method, options = {})
    methods_to_intercept = Array(options[:only])
    interceptor = instance_variable_get(:@_interceptor_module)

    methods_to_intercept.each do |method_name|
      # Definimos dinamicamente o método interceptador DENTRO do módulo prepended
      interceptor.define_method(method_name) do |*args, &block|
        # 1. Executa a validação/callback no contexto da instância
        send(callback_method) 
        
        # 2. Chama o método original da classe usando o `super`
        super(*args, &block)
      end
    end
  end
end


# Exemplo Prático de Uso
# Agora, vamos criar um controller que herda de BaseController, define alguns métodos e aplica o before_action.

class UsersController < BaseController
  # Define que o método :authenticate deve rodar antes do :show e :edit
  before_action :authenticate, only: [:show, :edit]

  def index
    puts "=> Executando: index (Lista todos os usuários)"
  end

  def show
    puts "=> Executando: show (Mostra perfil do usuário)"
  end

  def edit
    puts "=> Executando: edit (Tela de edição)"
  end

  private

  def authenticate
    puts "[Validation] Verificando se o usuário está logado..."
  end
end

# --- Testando a execução ---

controller = UsersController.new

puts "--- Chamando INDEX (Não deve disparar a validação) ---"
controller.index

puts "\n--- Chamando SHOW (Deve disparar a validação) ---"
controller.show

puts "\n--- Chamando EDIT (Deve disparar a validação) ---"
controller.edit