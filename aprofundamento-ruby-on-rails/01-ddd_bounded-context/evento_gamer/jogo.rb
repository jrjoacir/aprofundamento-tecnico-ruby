module EventoGamer
  class Jogo
    GENERO = [:acao, :aventura, :luta, :rpg, :plataforma, :puzzle]

    attr_reader :id, :slug, :nome, :descricao, :genero, :classificacao_indicativa

    def initialize(nome, descricao, genero, classificacao_indicativa)
      @id = "#{(Time.now.to_f * 1000).to_i}#{rand(100...999)}"
      @slug = nome.downcase.sub(' ', '-')
      @nome = nome
      @descricao = descricao
      @genero = genero
      @classificacao_indicativa = classificacao_indicativa
    end

    def criar
      {
        id: id,
        slug: slug,
        nome: nome,
        descricao: descricao,
        genero: genero,
        classificacao_indicativa: classificacao_indicativa
      }
    end
  end
end