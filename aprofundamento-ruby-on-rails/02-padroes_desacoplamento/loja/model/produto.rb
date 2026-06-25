module Loja
  module Model
    class Produto < ORM
      attr_reader :id, :slug, :nome, :valor, :classificacao_indicativa

      def initialize(nome, valor, classificacao_indicativa)
        @id = "#{(Time.now.to_f * 1000).to_i}#{rand(100...999)}"
        @slug = nome.downcase.sub(' ', '-')
        @nome = nome
        @valor = valor
        @classificacao_indicativa = classificacao_indicativa
      end
    end
  end
end
