module Loja
  module Presenter
    class Produto
      def initialize(produto)
        @produto = produto
      end

      def to_h
        {
          id: produto.id,
          slug: produto.slug,
          nome: produto.nome,
          valor: produto.valor,
          classificacao_indicativa: classificacao_indicativa
        }
      end

      private

      attr_reader :produto

      def classificacao_indicativa
        return 'Para todos os públicos' if produto.classificacao_indicativa == 0

        "Não recomendado para menores de #{produto.classificacao_indicativa} anos"
      end
    end
  end
end