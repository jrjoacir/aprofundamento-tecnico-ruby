module Estoque
  module Escutadores
    class Produto
      def self.inicializar_escutador!
        # O estoque se inscreve no evento da loja assim que o sistema inicia
        PubSub::Broker.inscrever(:produto_criado) do |payload|
          puts "📦 [Estoque] Recebi a notificação! Criando SKU baseado no produto comercial..."
          
          # Aqui entra a ACL (Camada anticorrupção): Traduzimos o payload da Loja
          # para a linguagem ubíqua do Jogo.         
          sku = Estoque::Sku.new(payload[:nome], nil, nil).criar
          puts "   -> SKU Criado com sucesso: #{sku.inspect}"
        end
      end
    end
  end
end

Estoque::Escutadores::Produto.inicializar_escutador!
