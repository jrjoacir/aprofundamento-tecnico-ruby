module Loja
  class Produto
    CLASSIFICACAO_INDICATIVA = [6, 10, 12, 14, 16, 18]

    attr_reader :id, :slug, :nome, :valor, :classificacao_indicativa

    def initialize(nome, valor, classificacao_indicativa)
      @id = "#{(Time.now.to_f * 1000).to_i}#{rand(100...999)}"
      @slug = nome.downcase.sub(' ', '-')
      @nome = nome
      @valor = valor
      @classificacao_indicativa = classificacao_indicativa
    end

    def to_h
      {
        id: id,
        slug: slug,
        nome: nome,
        valor: valor,
        classificacao_indicativa: classificacao_indicativa
      }
    end

    def criar
      PubSub::Broker.publicar(:produto_criado, self.to_h)
      self
    end

    def atualizar
      PubSub::Broker.publicar(:atualizar_produto, self.to_h)
      self
    end
  end
end
