module Loja
  module Service
    module Produto
      class Criar
        PARAMETROS_PERMITIDOS = [:nome, :valor, :classificacao_indicativa]

        def initialize(params)
          @params = params
        end

        def execute
          Loja::FormObject::Produto::Criar.new(params_tratados).validar
          produto = Loja::Model::Produto.new(
            params_tratados[:nome],
            params_tratados[:valor],
            params_tratados[:classificacao_indicativa]
          ).criar
          PubSub::Broker.publicar(:produto_criado, produto)
          produto
        end

        private

        attr_reader :params

        def params_tratados
          @params_tratados ||= params.slice(*PARAMETROS_PERMITIDOS)
        end
      end
    end
  end
end
