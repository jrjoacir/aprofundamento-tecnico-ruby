# Explicação

No Ruby, `self` é uma palavra-chave que sempre aponta para o **objeto atual em execução** (o contexto atual). No entanto, o papel do `self` muda drasticamente dependendo do escopo léxico onde ele é invocado.

Compreender o `self` é vital porque ele altere a forma como métodos sem receptor explícito são resolvidos.

- **Top-level:** Fora de qualquer classe/módulo, self aponta para um objeto especial chamado main (uma instância de Object).
- **No corpo de uma Classe/Módulo:** self aponta para o próprio objeto Classe ou Módulo.
- **Em métodos de Instância:** self aponta para a instância específica que chamou o método.
- **Em métodos de Classe:** self aponta para o objeto Classe.
- **Dentro de instance_eval:** self é alterado para o objeto que recebeu o bloco.
- **Dentro de class_eval:** self é alterado para a classe que recebeu o bloco.

**Links para Aprofundamento:**

- ~~Ruby-Doc: Control Expressions & Self~~
- ~~AppSignal: Dissecting Self in Ruby~~

# Entendendo melhor

Dominar o `self` é, sem exageros, o maior divisor de águas no Ruby. Se você compreende exatamente quem é o `self` a cada linha de código, você ganha a habilidade de ler metaprogramação complexa (como o código-fonte do Rails) como se fosse um livro infantil.

Vamos destrinchar o `self` de forma ultra-didática, entendendo a sua mecânica oculta e analisando cenários reais.

## O que é o `self`, afinal?

No Ruby, **toda** linha de código está sendo executada dentro de um objeto. O `self` é uma palavra-chave do sistema que aponta para **o objeto que possui o controle da execução naquele exato milissegundo**.

Ele serve a dois propósitos principais:

- **O Receptor Padrão (Default Receiver):** Se você chama um método sem especificar quem é o dono dele (ex: apenas `puts "Oi"` em vez de `objeto.puts`), o Ruby assume que o receptor é o `self`.
- **Armazenamento de Estado:** É através do `self` que o Ruby sabe onde buscar e salvar as variáveis de instância (`@variavel`).

Vamos mapear os **5 contextos fundamentais** onde o `self` muda de identidade:


| Contexto Léxico                | Quem é o self?                | Exemplo de Identidade                     |
| ------------------------------ | ----------------------------- | ----------------------------------------- |
| **Top-level** (Fora de tudo)   | O objeto `main`               | Uma instância especial de `Object`        |
| **Corpo de uma Classe/Módulo** | A própria Classe ou Módulo    | O objeto `User` (da classe `Class`)       |
| **Método de Instância**        | A instância específica criada | `#<User:0x00007f...>`                     |
| **Método de Classe**           | A própria Classe              | O objeto `User`                           |
| **Dentro de `instance_eval`**  | O objeto que recebeu o método | Qualquer objeto que você queira "invadir" |


## Exemplos Detalhados e Passo a Passo

### Nível: Iniciante (O Camaleão do Escopo)

Aqui vamos ver como o `self` muda de identidade conforme o código "entra" em novas estruturas.

```ruby
# Contexto 1: Top-level
puts "1. No topo do arquivo, self é: #{self} (Classe: #{self.class})"
# => 1. No topo do arquivo, self é: main (Classe: Object)

class ContaBancaria
  # Contexto 2: Corpo da Classe
  puts "2. No corpo da classe, self é: #{self}"
  # => 2. No corpo da classe, self é: ContaBancaria

  def inicializar_saldo
    # Contexto 3: Método de Instância
    puts "3. No método de instância, self é: #{self}"
  end
end

# Executando para ver o método de instância
conta = ContaBancaria.new
conta.inicializar_saldo
# => 3. No método de instância, self é: #<ContaBancaria:0x000055c...>
```

**Por que isso acontece?**

- No **Contexto 1**, o Ruby cria um objeto "embrulho" chamado `main` para que você possa rodar códigos soltos.
- No **Contexto 2**, quando o interpretador lê `class ContaBancaria`, ele cria um objeto do tipo `Class` cujo nome é `ContaBancaria`. Durante a leitura do corpo, o `self` é esse objeto.
- No **Contexto 3**, o método só roda quando a instância `conta` o chama. Portanto, `self` se torna essa instância específica.

### Nível: Intermediário (O Gotcha dos Setters e Métodos Privados)

Um dos maiores erros de desenvolvedores Pleno/Sênior vindos de outras linguagens é esquecer como o `self` se comporta com métodos modificadores (setters) e escopos privados.

```ruby
class Atleta
  attr_accessor :status, :pontos

  def initialize
    @status = "Inativo"
    @pontos = 0
  end

  def ativar_atleta_errado
    # Tentativa de mudar o status sem self explícito
    status = "Ativo" 
  end

  def ativar_atleta_correto
    # Uso correto do self explícito para setters
    self.status = "Ativo" 
  end

  def registrar_pontos
    # Ruby 3+: self pode chamar métodos privados explicitamente.
    # Em versões antigas (Ruby 2.6-), self.notificar geraria erro.
    self.notificar 
  end

  private

  def notificar
    puts "Atleta atualizado!"
  end
end

atleta = Atleta.new
atleta.ativar_atleta_errado
puts "Status após método errado: #{atleta.status}" # => "Inativo"

atleta.ativar_atleta_correto
puts "Status após método correto: #{atleta.status}" # => "Ativo"
```

**A Armadilha Explicada**

No método `ativar_atleta_errado`, quando escrevemos `status = "Ativo"`, o Ruby assume que estamos criando uma variável local chamada `status` naquele escopo, ignorando o método setter `status=`. Para invocar um método modificador, o Ruby exige um receptor explícito. Portanto, o uso do `self.status =` é obrigatório.

### Nível: Avançado (Sequestro de Contexto com `instance_eval`)

No nível sênior, alteramos o `self` dinamicamente para construir DSLs (Domain Specific Languages) limpas, como as rotas do Rails ou configurações do RSpec.

```ruby
class Relatorio
  def initialize
    @linhas = []
  end

  def adicionar_linha(texto)
    @linhas << texto
  end

  def imprimir
    puts @linhas.join("\n")
  end
end

class GeradorDeDSL
  def self.construir(&bloco)
    relatorio = Relatorio.new
    
    # O segredo está aqui: instance_eval altera o 'self' de dentro do bloco
    # para passar a ser a instância de 'relatorio'.
    relatorio.instance_eval(&bloco)
    
    relatorio
  end
end

# Uso da DSL: repare que não precisamos passar variáveis no bloco (ex: |r| r.adicionar_linha)
novo_relatorio = GeradorDeDSL.construir do
  # Quem é o self aqui dentro? É a instância de Relatorio!
  adicionar_linha "--- Relatório de Performance ---"
  adicionar_linha "CPU: 12%"
  adicionar_linha "RAM: 45%"
end

novo_relatorio.imprimir
```

**Por que isso é poderoso?**

Ao executar `relatorio.instance_eval(&bloco)`, nós "sequestramos" o escopo do bloco enviado pelo usuário. Métodos chamados lá dentro sem receptor (como `adicionar_linha`) agora são direcionados diretamente para o objeto `relatorio`, porque ele se tornou o `self` temporário daquela execução.