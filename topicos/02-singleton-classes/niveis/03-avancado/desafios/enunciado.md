# Desafio Avançado

Crie um método macro chamado `class_attribute` (semelhante ao do ActiveSupport do Rails). Quando declarado na classe pai, ele deve gerar métodos de leitura e escrita de classe. Se uma classe filha herdar dessa classe pai, ela deve herdar o valor atual, mas se a classe filha alterar o valor, a alteração não deve afetar a classe pai. Use Singleton Classes para isolar o estado.

# Detalhando o desafio

## 1. O Problema: Por que precisamos de `class_attribute`?

Imagine que você está construindo um framework (como o Rails) ou uma biblioteca interna. Você quer que as classes tenham configurações específicas, e que as classes filhas herdem essas configurações, mas possam customizá-las sem estragar a classe pai.

Se tentarmos fazer isso com o que o Ruby oferece nativamente, nós quebramos a cara de duas formas:

### Tentativa A: Usando Variáveis de Classe (`@@`)

As variáveis de classe em Ruby são perigosas porque elas são **compartilhadas** por toda a árvore de herança.

```ruby
class ApplicationRepository
  @@db_connection = "Produção"
end

class TestRepository < ApplicationRepository
  # O desenvolvedor tenta alterar APENAS no ambiente de teste
  @@db_connection = "Mock/Testes" 
end

# O DESASTRE:
puts ApplicationRepository.class_eval { @@db_connection } 
# => "Mock/Testes" (A classe filha alterou o valor na classe pai!)
```

### Tentativa B: Usando Variáveis de Instância de Classe (`@`)

Se usarmos uma variável de instância no escopo da classe, o pai fica isolado do filho, mas o filho **não herda** o valor inicial do pai.

```ruby
class ApplicationRepository
  class << self; attr_accessor :db_connection; end
  @db_connection = "Produção"
end

class TestRepository < ApplicationRepository; end

# O PROBLEMA:
puts TestRepository.db_connection 
# => nil (O filho não herdou o valor "Produção")
```

## 2. O Comportamento Esperado (O Alvo do Desafio)

O objetivo do seu macro `class_attribute` é criar um meio-termo perfeito. O comportamento do seu código final deve ser exatamente este:

```ruby
class APIClient
  # Seu método macro sendo chamado
  class_attribute :timeout
  
  self.timeout = 30 # Definindo no Pai
end

class FastAPIClient < APIClient
  # 1. Ele deve HERDAR o valor do pai automaticamente:
  # FastAIClient.timeout deve retornar 30
  
  # 2. Se o filho alterar, deve ser isolado:
  self.timeout = 5 
end

# 3. O PAI NÃO PODE SER AFETADO:
puts APIClient.timeout     # Deve continuar sendo 30
puts FastAPIClient.timeout # Deve ser 5
```

## 3. A Mecânica Oculta: Como as Singleton Classes se herdam?

Aqui está o "pulo do gato" que torna este desafio um nível Avançado.

Quando você faz `class Child < Parent`, o Ruby não cria herança apenas entre as instâncias. **A Singleton Class do Filho herda da Singleton Class do Pai**.

A cadeia de ancestrais da Singleton Class do `FastAPIClient` se parece com isso:

```ruby
FastAPIClient.singleton_class.ancestors
# => [#<Class:FastAPIClient>, #<Class:APIClient>, #<Class:Object>, ...]
```

Isso significa que se você chamar `FastAPIClient.timeout` (um método de classe), o Ruby vai buscar esse método primeiro na Singleton Class do filho. Se não achar, ele vai subir para a Singleton Class do pai!

### Como usar isso a seu favor no desafio?

Para resolver o desafio, você precisará jogar com o escopo de onde as variáveis e os métodos são definidos:

1. **O Getter (Leitura)**: Se o filho não tiver um valor próprio definido em sua própria Singleton Class, ele deve de alguma forma olhar para cima na cadeia e pegar o valor do pai. (Dica: métodos de instância comuns da Singleton Class conseguem acessar variáveis de instância daquela classe específica).

2. **O Setter (Escrita)**: Quando você chama `FastAPIClient.timeout = 5`, o método setter não pode simplesmente alterar uma variável que o pai está lendo. Ele precisa, dinamicamente, "cravar" esse novo valor diretamente na Singleton Class do filho, cortando o vínculo de leitura com o pai daquele momento em diante.

### Onde o seu Macro vai agir?

Você precisará criar esse método `class_attribute` dentro da classe `Class` (ou em um módulo que estenda todas as classes), de forma que ele possa ser chamado dentro do corpo de qualquer classe. Quando chamado, ele usará metaprogramação (`define_method`, `class_eval`, etc.) para injetar esses comportamentos customizados de leitura e escrita nas Singleton Classes.
