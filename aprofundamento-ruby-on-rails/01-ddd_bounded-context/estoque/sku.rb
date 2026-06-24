module Estoque
  class Sku
    attr_reader :id, :slug, :nome, :volume, :peso

    def initialize(nome, volume = nil, peso = nil)
      @id = "#{(Time.now.to_f * 1000).to_i}#{rand(100...999)}"
      @slug = nome.downcase.sub(' ', '-')
      @volume = volume
      @peso = peso
    end

    def criar
      {
        id: id,
        slug: slug,
        volume: volume,
        peso: peso
      }
    end
  end
end