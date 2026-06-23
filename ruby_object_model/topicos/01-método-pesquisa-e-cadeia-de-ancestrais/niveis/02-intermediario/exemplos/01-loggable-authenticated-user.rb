# Nível: Intermediário
# Diferença prática na ordem de execução entre include e prepend.
  
module Loggable
  def greet
    "Log: Calling greet -> " + super
  end
end

module Authenticated
  def greet
    "Auth: Checking permissions -> " + super
  end
end

class User
  include Loggable
  prepend Authenticated

  def greet
    "Hello User!"
  end
end

# Cadeia de Ancestrais de User: [Authenticated, User, Loggable, Object...]
puts User.ancestors.inspect
puts User.new.greet
# Resultado feito pela IA (Gemini):
# => "Auth: Checking permissions -> Log: Calling greet -> Hello User!"

# O resultado do teste foi o seguinte:
# => "Auth: Checking permissions -> Hello User!"
