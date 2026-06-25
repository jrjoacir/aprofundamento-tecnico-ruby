require_relative 'orm.rb'
require_relative 'broker.rb'
require_relative 'loja/model/produto.rb'
require_relative 'loja/presenter/produto.rb'
require_relative 'loja/query_object/produto.rb'
require_relative 'loja/form_object/produto/base.rb'
require_relative 'loja/form_object/produto/criar.rb'
require_relative 'loja/service/produto/criar.rb'
require_relative 'loja/controller/produto.rb'
require_relative 'loja/controller/produto.rb'

params = { nome: 'Jogo 1', valor: 123, classificacao_indicativa: 10 }
puts Loja::Controller::Produto.criar(params)