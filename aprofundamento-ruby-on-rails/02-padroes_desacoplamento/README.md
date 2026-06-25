Quando uma aplicação cresce, o lema do Rails ("Skinny Controller, Fat Model") torna-se uma armadilha. O Model (`ActiveRecord`) passa a ter responsabilidades demais: ele valida dados do formulário, faz queries gigantescas no banco, formata strings para a tela e executa regras de negócio complexas. O resultado? Modelos com milhares de linhas que ninguém consegue testar ou alterar com segurança.

Os **Padrões de Desacoplamento** servem para fatiar essas responsabilidades em pequenas classes Ruby puras (**POROs** - *Plain Old Ruby Objects*), onde cada uma faz apenas uma coisa extremamente bem.

## 1. O Básico: Decorators / Presenters (Lógica de Exibição)

**O Problema:** Você precisa exibir o nome do usuário em caixa alta, ou formatar a data de criação no padrão brasileiro (`DD/MM/AAAA`), ou ainda gerar um hash JSON customizado para uma API. Se você colocar métodos como `data_formatada` ou `nome_completo_maiusculo` dentro do Model, estará poluindo a camada de dados com regras que pertencem puramente à interface (View/JSON).

**A Solução:** O **Decorator** ou **Presenter** envolve o seu modelo e adiciona a ele apenas métodos de formatação visual.

### Exemplo em Código (Básico)

Imagine o modelo `Jogo` que você criou anteriormente. Em vez de entupir o arquivo original, criamos um Presenter:

```ruby
# app/presenters/jogo_presenter.rb
class JogoPresenter
  def initialize(jogo)
    @jogo = jogo # Recebe o objeto original do domínio
  end

  # Transforma o valor numérico em uma string amigável para a tela
  def preco_formatado
    return "Gratuito" if @jogo.valor.nil? || @jogo.valor.zero?
    
    "R$ #{sprintf('%.2f', @jogo.valor).gsub('.', ',')}"
  end

  # Formata o selo de classificação indicativa
  def selo_classificacao
    if @jogo.classificacao_indicativa >= 18
      "🔞 [+18] Conteúdo Adulto"
    else
      "🧒 [#{@jogo.classificacao_indicativa}+] Livre"
    end
  end
end
```

### Como usar no Controller/Main:

```ruby
jogo_do_banco = Loja::Produto.new('Rayman Legends', 275.99, 6)

# Envolvemos o objeto no Presenter na hora de exibir
presenter = JogoPresenter.new(jogo_do_banco)

puts presenter.preco_formatado   # Saída: R$ 275,99
puts presenter.selo_classificacao # Saída: 🧒 [6+] Livre
```

## 2. O Intermediário: Query Objects & Form Objects

Aqui começamos a limpar o banco de dados e as requisições HTTP da sua aplicação.

### 2.1 Query Objects (Isolando SQL Complexo)

**O Problema:** No Rails, é comum encadear escopos (`scopes`) gigantescos. Exemplo: `Jogo.ativos.da_categoria(:rpg).com_estoque.criados_este_mes`. Conforme o SQL fica complexo (com `joins`, `group` e subqueries), o Model vira um caos ilegível.

**A Solução:** O **Query Object** isola essa consulta complexa em uma classe dedicada que possui apenas uma responsabilidade: retornar um conjunto de dados filtrados.

#### Exemplo em Código (Intermediário)

```ruby
# app/queries/jogos_populares_disponiveis_query.rb
class JogosPopularesDisponiveisQuery
  def initialize(relation = Jogo.all)
    @relation = relation # Permite passar um escopo inicial (útil para paginação)
  end

  def call(limite: 10)
    # Isola todo o comportamento complexo de filtros SQL
    @relation
      .where(ativo: true)
      .where('visualizacoes > ?', 5000)
      .where.not(estoque_atual: 0)
      .order(classificacao_review: :desc)
      .limit(limite)
  end
end
```

**Benefício:** No seu controller, você substitui uma query de 10 linhas por: `JogosPopularesDisponiveisQuery.new.call(limite: 5)`. É incrivelmente fácil de testar isoladamente sem precisar simular requisições HTTP.

### 2.2 Form Objects (Validações fora do Model)

**O Problema:** No banco de dados, para salvar um Usuário, você só precisa de `email` e `senha`. Mas, na tela de cadastro da sua aplicação, você exige que ele marque um checkbox de *"Aceito os Termos de Uso"*. Se você colocar `validates :aceitou_termos, acceptance: true` no seu Model, você vai quebrar a criação de usuários via API ou via console, onde esse campo não faz sentido. Validação de formulário **não é** validação de banco.

**A Solução:** O **Form Object** é uma classe que representa estritamente os campos que vêm da tela. Ele valida as regras daquela requisição específica e, se tudo estiver correto, salva o modelo real.

#### Exemplo em Código (Intermediário)

```ruby
# app/forms/cadastro_jogo_form.rb
class CadastroJogoForm
  # No Rails, incluiríamos ActiveModel::Model para ganhar métodos como .valid?
  attr_reader :errors, :params

  def initialize(params)
    @params = params
    @errors = {}
  end

  def valid?
    # Validações contextuais da tela
    if params[:nome].to_s.strip.empty?
      @errors[:nome] = "não pode ficar em branco"
    end

    unless params[:aceitou_termos_distribuicao] == true
      @errors[:termos] = "precisam ser aceitos para publicar o jogo"
    end

    @errors.empty?
  end

  def save
    return false unless valid?

    # Se estiver válido, aí sim instanciamos o objeto de domínio real
    # Repare que filtramos o 'aceitou_termos_distribuicao', pois o banco não precisa dele
    Loja::Produto.new(params[:nome], params[:valor], params[:classificacao]).criar
    true
  end
end
```

## 3. O Avançado: Service Objects / Operations (Orquestração de Regras de Negócio)

Este é o padrão mais importante da lista para quem trabalha em aplicações gigantes.

**O Problema:** Um caso de uso do mundo real raramente faz apenas um `insert` no banco. Pensando na jornada de compra de um jogo:

1. Validar os dados do cartão.
2. Criar a cobrança na API do Gateway (ex: Juno/Stripe).
3. Alterar o status do pedido para "Pago".
4. Baixar o item do Estoque.
5. Disparar e-mail com a chave de ativação.
6. Publicar um evento (`:pedido_pago`) para o ecossistema.

Se você colocar isso no Controller, ele fica gigante e impossível de reaproveitar. Se colocar em callbacks do Model (`after_save :baixar_estoque`), você cria efeitos colaterais perigosos (ex: toda vez que alterar o nome do jogo no admin, o callback roda e altera o estoque sem querer).

**A Solução:** O **Service Object** encapsula uma **ação de negócio**. Ele orquestra os Form Objects, os Models, as chamadas de API externas e os disparos de eventos de forma sequencial e isolada.

### Exemplo em Código (Avançado)

Vamos juntar tudo o que aprendemos (incluindo o `Broker` de Pub/Sub que você criou na etapa anterior) em um único Service Object robusto de Checkout:

```ruby
# app/services/checkout/finalizar_compra_service.rb
module Checkout
  class FinalizarCompraService
    class FalhaNoCheckout < StandardError; end

    def initialize(carrinho_params)
      @params = carrinho_params
    end

    def execute
      puts "\n🚀 [SERVICE] Iniciando processo de Checkout do pedido..."

      # 1. Executa um Form Object para validar regras da requisição
      # (Ex: se o cupom expirou, se preencheu o endereço corretamente)
      form = CheckoutForm.new(@params)
      unless form.valid?
        return { sucesso: false, erros: form.errors }
      end

      # 2. Executa a lógica de cobrança financeira externa
      gateway_aprovado = cobrar_no_cartao_de_credito(@params[:cartao_token], @params[:total])
      raise FalhaNoCheckout, "Pagamento recusado pela operadora" unless gateway_aprovado

      # 3. Criação de registros internos (Interação com o Domínio/Model)
      pedido = Faturamento::Pedido.new(@params[:usuario_id], @params[:itens]).salvar

      # 4. Comunicação Reativa (Uso do seu padrão Pub/Sub!)
      # Notificamos o resto da empresa de que a compra foi um sucesso
      PubSub::Broker.publicar(:compra_finalizada, {
        pedido_id: pedido[:id],
        usuario_email: @params[:email],
        itens: @params[:itens]
      })

      { sucesso: true, pedido_id: pedido[:id] }
    rescue FalhaNoCheckout => e
      { sucesso: false, erro_critico: e.message }
    end

    private

    def cobrar_no_cartao_de_credito(token, valor)
      # Simula integração com Stripe/Adyen/Pagar.me
      puts "💳 [Gateway] Cobrando R$ #{valor} no cartão tokenizado..."
      true
    end
  end
end

# Dublê rápido de comportamento para o exemplo rodar:
module Faturamento
  class Pedido
    def initialize(usr, itens); end
    def salvar; { id: rand(10000..99999) }; end
  end
end
class CheckoutForm
  def initialize(p); end
  def valid?; true; end
end
```

### Como o Controller se beneficia disso?

O seu controller do Rails deixa de ser um monstro de regras e passa a ser apenas um repassador de ordens magro:

```ruby
class CheckoutsController < ApplicationController
  def create
    resultado = Checkout::FinalizarCompraService.new(params[:carrinho]).execute

    if resultado[:sucesso]
      render json: { mensagem: "Sucesso!", id: resultado[:pedido_id] }, status: :created
    else
      render json: { erros: resultado[:erros] || resultado[:erro_critico] }, status: :unprocessable_entity
    end
  end
end
```

## 4. Visão Holística: Como tudo se conecta?

Imagine o ciclo de vida de uma única requisição HTTP dentro de um monólito escalável usando esses padrões:

1. O **Controller** recebe os dados da requisição HTTP.
2. Ele passa esses dados brutos para um **Form Object** validar a entrada do usuário.
3. Se válido, o Controller aciona o **Service Object** responsável por aquela ação.
4. O Service usa um **Query Object** para buscar dados específicos e complexos do banco de dados.
5. O Service altera as entidades do **Model** (`ActiveRecord`).
6. O Service publica um evento no **Broker/PubSub** para avisar outros contextos.
7. O Controller pega o resultado e envelopa em um **Presenter/Decorator** para cuspir o JSON ou a tela perfeitamente formatada para o cliente.

O seu modelo (`ActiveRecord`) volta a fazer apenas o que ele foi desenhado para fazer: **conversar com a tabela do banco de dados**.

## Onde aprender mais? (Referências obrigatórias para o PDI)

- **Artigo Clássico da Code Climate: [7 Patterns to Refactor Fat ActiveRecord Models](https://codeclimate.com/legacy/7-ways-to-decompose-fat-activerecord-models)** – Este é o texto sagrado que popularizou o uso desses objetos (Form, Query, Service, Decorator) na comunidade Rails mundial. Leitura indispensável.
- **Livro: "Architecture Patterns with Python" (ou Ruby equivalente)** – Embora focado em Python, os conceitos de *Service Layer* e *Repository Pattern* explicados graficamente se aplicam perfeitamente ao ecossistema Ruby/Rails de alta performance.
- **Framework Alternativo: [Trailblazer](https://trailblazer.to/)** – Se você quer ver uma estrutura profissional que padroniza o uso de *Operations* (Service Objects avançados) e *Forms*, estude a documentação do Trailblazer. Muitas empresas usam essa arquitetura por cima do Rails para domar monólitos gigantes.
- **Abordagem Funcional: [Dry-rb (dry-transaction / dry-validation)*](https://dry-rb.org/)** – Uma coleção de gems Ruby excepcionais focadas em criar Service Objects baseados em passos de execução e validações corporativas complexas sem herdar nada do Rails.
