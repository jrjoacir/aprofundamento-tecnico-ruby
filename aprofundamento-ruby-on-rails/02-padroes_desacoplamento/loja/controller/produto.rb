module Loja
  module Controller
    class Produto
      class << self
        def criar(params)
          produto = Loja::Service::Produto::Criar.new(params).execute
          { http_status: 201, data: Loja::Presenter::Produto.new(produto).to_h }
        rescue => erro
          { http_status: 422, mensagem_de_erro: erro.message }
        end
      end
    end
  end
end
