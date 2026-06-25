module Loja
  module QueryObject
    module Produto
      class << self
        def apenas_para_adultos(classific_minima = 18)
          produtos.select { |produto| produto.classificacao_indicativa >= classific_minima }
        end

        def com_valor_a_partir_de(valor)
          produtos.select { |produto| produto.valor >= valor }
        end

        def apenas_para_adultos_com_valor_a_partir_de(valor)
          apenas_para_adultos.intersection(com_valor_a_partir_de(valor))
        end

        private

        def produtos
          Loja::Model::Produto.listar
        end
      end
    end
  end
end
