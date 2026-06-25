class LegacyClass
  def save
    "Legacy saved!"
  end
end

module Mongo
  def save
    "Mongo saved!"
  end
end

module SqlServer
  def save
    "SqlServer saved!"
  end
end

module Postgres
  def save
    "Postgres saved!"
  end
end

class Document < LegacyClass
  include Mongo
  include Postgres
  include SqlServer
end

Document.new.method(:save).owner
# => SqlServer

# O método owner para a invocação do método save, responde o último
# módulo adicionado para a classe Document.