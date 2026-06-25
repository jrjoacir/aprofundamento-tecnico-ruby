module Loja
  module FormObject
    module Produto
      class Base
        CLASSIFICACAO_INDICATIVA = [0, 6, 10, 12, 14, 16, 18]
        NOME = { tamanho_minimo: 2, tamanho_maximo: 200}
        VALOR = { minimo: 0 }

        def initialize(params)
          @params = params
        end

        def validar
          validar_classificacao_indicativa!
          validar_nome!
          validar_valor!
        end

        private

        attr_reader :params

        def validar_classificacao_indicativa!
          valido = CLASSIFICACAO_INDICATIVA.include?(params[:classificacao_indicativa])
          raise 'Classificação indicativa inválida' unless valido
        end

        def validar_nome!
          valido = params[:nome].length.between?(NOME[:tamanho_minimo], NOME[:tamanho_maximo])
          raise "Nome deve ter entre #{NOME[:tamanho_minimo]} e #{NOME[:tamanho_maximo]} caracteres" unless valido
        end

        def validar_valor!
          valor = params[:valor] || -1
          raise 'Valor deve ser maior ou igual a zero' if valor < VALOR[:minimo]
        end
      end
    end
  end
end