module EventoGamer
  module Escutadores
    class Produto
      def self.inicializar_escutador!
        # O evento gamer se inscreve no evento da loja assim que o sistema inicia
        PubSub::Broker.inscrever(:produto_criado) do |payload|
          puts "🎮 [EventoGamer] Novo jogo detectado no mercado comercial! Adicionando ao catálogo..."
          
          # Aqui entra a ACL (Camada anticorrupção): Traduzimos o payload da Loja
          # para a linguagem ubíqua do Jogo.         
          jogo = EventoGamer::Jogo.new(payload[:nome], nil, nil, payload[:classificacao_indicativa]).criar
          puts "   -> Jogo adicionado ao Catálogo Gamer: #{jogo.inspect}"
        end
      end
    end
  end
end

EventoGamer::Escutadores::Produto.inicializar_escutador!
