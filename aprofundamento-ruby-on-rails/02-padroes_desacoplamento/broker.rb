module PubSub
  class Broker
    @inscritos = Hash.new { |hash, chave| hash[chave] = [] }

    # Permite que um escutador assine um evento passando um bloco de código (callback)
    def self.inscrever(evento, &bloco)
      @inscritos[evento] << bloco
    end

    # Transmite o payload para todos os blocos inscritos naquele evento
    def self.publicar(evento, payload)
      puts "\n📢 [BROKER] Evento '#{evento}' publicado!"
      @inscritos[evento].each { |bloco| bloco.call(payload) }
    end
  end
end