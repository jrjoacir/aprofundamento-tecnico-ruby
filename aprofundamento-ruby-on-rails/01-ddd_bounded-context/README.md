Vamos desmistificar o Domain-Driven Design (DDD) focado em Bounded Contexts, partindo da teoria básica até como isso se traduz em código Rails e arquitetura de microsserviços.

## 1. O Básico: O que é DDD e o bendito Bounded Context?

Antes de falar de código, precisamos falar de **negócio**. O DDD prega que o software deve ser moldado exatamente como o negócio funciona.

No centro do DDD, temos dois conceitos vitais:

- **Linguagem Ubíqua:** É o vocabulário comum compartilhado por desenvolvedores e especialistas de negócio (Product Managers, suporte, vendas). Se o pessoal de negócios chama um usuário de "Lead", o código deve usar "Lead", não "User".

- **Bounded Context (Contexto Delimitado):** É a fronteira conceitual onde um modelo de domínio específico se aplica. Dentro dessa fronteira, as palavras têm um único significado absoluto.

### O Problema do Modelo Único (O erro do Rails puro)

Imagine uma aplicação gigante. Se criarmos um modelo chamado User ou Client para a aplicação inteira, ele vai começar a acumular atributos e comportamentos de todas as áreas da empresa.

- Para o time de **Marketing**, o cliente tem origem_do_lead, score, emails_clicados.
- Para o time de *Vendas (CRM)*, o cliente tem estagio_do_funil, valor_estimado, vendedor_responsavel.
- Para o time de **Faturamento (Billing)**, o cliente tem cartao_de_credito, endereco_de_cobranca, cnpj.

Se você colocar tudo isso em um único ActiveRecord chamado User.rb, você terá um arquivo de 5.000 linhas ilegível e perigoso.

### A Solução com Bounded Context

Em vez de um modelo global, nós dividimos o sistema em contextos menores. Cada contexto tem a sua própria definição do que é aquele objeto.

💡 **Exemplo Prático:** O "Cliente" não é uma tabela única. Ele existe como Marketing::Lead dentro do contexto de Marketing, como Sales::Account no contexto de CRM, e como Billing::Customer no contexto de Faturamento. Cada um no seu quadrado, com seu próprio banco de dados (ou tabelas) e regras.

## 2. O Intermediário: Modelando Bounded Contexts no Rails Monolítico

Você não precisa quebrar sua aplicação em 10 microsserviços para começar a usar Bounded Contexts. É totalmente possível (e altamente recomendado) aplicar isso dentro de um **único monólito Rails** usando namespaces e isolamento de pastas.

### Estrutura de Pastas (Namespaces)

Em vez de misturar tudo em `app/models/*`, nós separamos por contextos de negócio utilizando módulos Ruby.

app/

├── contexts/

│   ├── marketing/

│   │   ├── models/

│   │   │   └── lead.rb        # Marketing::Lead

│   │   └── services/

│   ├── sales/

│   │   ├── models/

│   │   │   └── opportunity.rb # Sales::Opportunity

│   └── billing/

│       ├── models/

│       │   └── invoice.rb     # Billing::Invoice

(Nota: Para o Rails carregar a pasta `app/contexts`, você precisará adicioná-la ao `config.autoload_paths`).

### Exemplo em Código

Veja como os modelos ficam magros e focados apenas no que importa para aquele contexto:

```ruby
# app/contexts/marketing/models/lead.rb
module Marketing
  class Lead < ApplicationRecord
    # Tabelas separadas por contexto (ex: marketing_leads)
    self.table_name = "marketing_leads" 
    
    validates :email, presence: true
    
    def score_interacao!
      # Lógica puramente de marketing
    end
  end
end

# app/contexts/billing/models/customer.rb
module Billing
  class Customer < ApplicationRecord
    self.table_name = "billing_customers"
    
    validates :cnpj, presence: true
    
    def inadimplente?
      # Lógica puramente de faturamento
    end
  end
end
```

Dessa forma, o time de faturamento pode alterar o modelo `Billing::Customer` sem o menor medo de quebrar as regras de pontuação de leads do time de marketing.

## 3. O Avançado: Comunicação entre Contextos (Monólito Modular vs. Microsserviços)

Conforme os contextos ficam isolados, surge o desafio avançado: **Como eles conversam entre si?** Se o `Marketing::Lead` fechar uma compra, como o contexto de `Billing` fica sabendo disso para gerar a nota fiscal?

Se você fizer uma chamada direta de banco de dados cruzando os contextos (ex: um `joins` entre tabelas de marketing e billing), você acabou de destruir o seu Bounded Context. O acoplamento voltou.

Temos duas estratégias principais para resolver isso, dependendo da infraestrutura:

## Cenário A: No Monólito Modular (Arquitetura Baseada em Eventos Internos)

Para evitar que um módulo chame o outro diretamente, utilizamos **Eventos Acadêmicos/Domínio**.

Quando algo relevante acontece em um contexto, ele publica um evento. Outros contextos assinam esse evento e reagem a ele. Ferramentas como a gem `wisper` ou soluções simples de Pub/Sub resolvem isso na memória do Rails.

```ruby
# 1. No contexto de Marketing, o Lead é convertido
module Marketing
  class ConvertLead
    include Wisper::Publisher

    def call(lead_id)
      lead = Lead.find(lead_id)
      # ... lógica de conversão ...
      
      # Publica o evento para quem quiser ouvir
      publish(:lead_converted, lead_id: lead.id, email: lead.email)
    end
  end
end

# 2. No contexto de Billing, um Listener fica "ouvindo"
module Billing
  class LeadConvertedListener
    def lead_converted(payload)
      # Cria o cliente no contexto de faturamento de forma isolada
      Billing::Customer.create!(
        external_marketing_id: payload[:lead_id],
        email: payload[:email]
      )
    end
  end
end
```

## Cenário B: Em Microsserviços (Mensageria)

Se a aplicação cresceu tanto que o monólito foi quebrado, os Bounded Contexts viram aplicações Rails independentes (ou em outras linguagens).

A comunicação que antes era em memória (via Gems) passa a ser assíncrona através de um **Message Broker** (como RabbitMQ ou Apache Kafka). O conceito de disparo de eventos continua exatamente o mesmo, mas agora trafegando via JSON/Protobuf pela rede.

### O conceito de ACL (Anti-Corruption Layer)

Em sistemas legados ou integrações complexas, um microsserviço precisa consumir dados de outro, mas não quer "corromper" seu próprio modelo mental com a bagunça do vizinho.

Criamos uma **Camada Anticorrupção (ACL)**. Ela traduz o que vem de fora para a Linguagem Ubíqua do seu contexto.

```ruby
# Dentro de Billing, recebemos um payload confuso do sistema legado de CRM
# A ACL traduz e limpa os dados antes de tocar no nosso domínio
module Billing
  class CrmAdapterACL
    def self.translate(external_payload)
      {
        billing_uid: external_payload[:id_crm_v3],
        tax_id: external_payload[:documento_legal], # Transforma em algo legível para nós
        value: external_payload[:amount_cents] / 100.0
      }
    end
  end
end
```

## Onde aprender mais? (Referências)

Para dominar esse assunto e enriquecer a defesa do seu PDI, recomendo fortemente o estudo destas fontes:

- **Livro: "Domain-Driven Design" (O Livro Azul) – Eric Evans:** Onde tudo começou. É uma leitura densa, mas focar nos capítulos sobre *Strategic Design* e *Bounded Contexts* já mudará sua mente.
- **Livro: "Implementando Domain-Driven Design" (O Livro Vermelho) – Vaughn Vernon:** Uma abordagem muito mais prática e voltada para desenvolvedores do que o livro do Evans.
- **Artigo: [Bounded Context (Martin Fowler)](https://martinfowler.com/bliki/BoundedContext.html):** A melhor, mais rápida e mais didática explicação curta sobre o conceito na internet.
- **Ferramenta/Ferramental: [Packwerk da Shopify](https://github.com/Shopify/packwerk):** A Shopify (que tem um dos maiores monólitos Rails do mundo) criou essa ferramenta em Ruby especificamente para impor e garantir as fronteiras de Bounded Contexts em monólitos, impedindo que um módulo acesse código do outro sem permissão. Vale muito a pena pesquisar a arquitetura deles.

