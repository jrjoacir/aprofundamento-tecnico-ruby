require_relative 'broker.rb'
require_relative 'loja/produto.rb'
require_relative 'evento_gamer/jogo.rb'
require_relative 'evento_gamer/escutadores/produto.rb'
require_relative 'estoque/sku.rb'
require_relative 'estoque/escutadores/produto.rb'

puts Loja::Produto.new('Rayman Legends', 275.99, 6).criar
