class ORM
  @@registros = {}

  def criar
    @@registros.merge!(self.class => {}) if @@registros[self.class].nil?
    @@registros[self.class].merge!(self.id => self)
    self
  end

  def atualizar
    @@registros[self.class].merge!(self.id => self)
    self
  end

  def remover
    @@registros[self.class].delete(self.id)
    self
  end

  class << self
    def listar
      @@registros[self].values
    end
  end
end
