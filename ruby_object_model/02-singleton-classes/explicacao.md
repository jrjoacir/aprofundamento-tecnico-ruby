# Explicação

Em Ruby, estruturas como "métodos de classe" na verdade não existem de forma isolada. Classes não podem ter métodos que instâncias não têm, a menos que usem um truque de arquitetura: a Singleton Class (também conhecida como Eigenclass ou Metaclass).

Cada objeto em Ruby (e lembre-se, classes também são objetos!) possui uma classe oculta, exclusiva para si. Quando você define um método diretamente em um objeto específico (`def objeto.metodo`),esse método é guardado na Singleton Class desse objeto.

No caso de métodos de classe (`def Self.meu_metodo`), o que está acontecendo é que o método está sendo adicionado à Singleton Class do objeto Class.

```
[Instância de User] -> [Singleton Class de User] -> [Classe User] -> [Singleton Class de Class] -> [Classe Class]
```

# Entendendo melhor

Para entender o que é uma **Eigenclasse** (também chamada de Singleton Class ou Metaclasse), imagine que o Ruby é um sistema extremamente organizado, mas que adora criar "quartos secretos" quando ninguém está olhando.

Para um iniciante, o conceito pode parecer abstrato, mas vamos destrinchá-lo parte por parte com analogias do dia a dia.

## 1. O que é uma Eigenclasse? (A Analogia do Caderno)

Em Ruby, quase tudo é um objeto. Quando você cria uma classe, ela funciona como um manual de instruções para criar objetos.

```ruby
class Cachorro
  def latir
    "Au au!"
  end
end

rex = Cachorro.new
thor = Cachorro.new
```

Aqui, tanto `rex` quanto `thor` sabem `latir`, porque ambos seguem o manual da classe `Cachorro`.

Mas imagine que o `rex` aprendeu um truque único: ele sabe dar a pata. Você não quer ensinar isso para o `thor` (e nem para nenhum outro cachorro do mundo), apenas para o `rex`.

No Ruby, você pode fazer isso:

```ruby
def rex.dar_a_pata
  "Dei a pata!"
end

puts rex.dar_a_pata # => "Dei a pata!"
# puts thor.dar_a_pata # => Erro! (NoMethodError)
```

Onde esse método `dar_a_pata` **ficou guardado**? Ele não pode estar na classe `Cachorro`, senão o `thor` também saberia fazer o truque. Ele também não pode ficar "solto" no objeto `rex`, porque objetos comuns não guardam métodos, apenas variáveis.

A resposta é: O Ruby, secretamente, criou uma classe oculta e exclusiva para o `rex`. Essa classe invisível, que fica entre o objeto `rex` e a classe `Cachorro`, é a **Eigenclasse**. É como se o `rex` ganhasse um caderno de anotações personalizado que só ele pode ler.

## 2. Como ela funciona por baixo dos panos?

Quando você chama um método em um objeto, o Ruby inicia uma busca (chamada de *Method Lookup*). A Eigenclasse é sempre o primeiro lugar onde o Ruby olha.

A ordem de busca para o nosso exemplo do `rex.dar_a_pata` funciona assim:

1. O Ruby se pergunta: "O `rex` tem uma Eigenclasse com o método `dar_a_pata`?" Sim! Então ele executa.

2. Se você chamasse `rex.latir`, o Ruby olharia na Eigenclasse (não acharia), depois iria para a classe `Cachorro` (onde acharia o método).


## 3. As 3 formas de interagir com a Eigenclasse

Existem formas diferentes de "abrir" esse quarto secreto no Ruby. Vamos ver as mais comuns:

### Forma 1: Definindo um método diretamente no objeto

É o que fizemos lá em cima. Você usa o nome do objeto, um ponto e o nome do método.

```ruby
texto = "Olá"

# Criando um método exclusivo para esta String
def texto.gritar
  self.upcase + "!!!"
end

puts texto.gritar # => "OLÁ!!!"
```

### Forma 2: Usando o método `.singleton_class`

O Ruby possui um método nativo que nos permite "ver" e interagir diretamente com essa classe secreta.

```ruby
minha_string = "Ruby"

# Isso nos mostra o objeto da Eigenclasse
puts minha_string.singleton_class 
# => #<Class:#<String:0x0000000115e5a288>>
```
(*Esse nome estranho na resposta é a forma do Ruby dizer: "Isto é a classe exclusiva deste objeto String específico".*)

### Forma 3: A sintaxe do "Double Arrow" (`class << objeto`)

Esta é a sintaxe que mais assusta iniciantes, mas ela apenas significa: "*Ruby, entre na Eigenclasse deste objeto agora*".

```ruby
animal = "Gato"

# Entrando na Eigenclasse do objeto 'animal'
class << animal
  def miar
    "Miau!"
  end
end

puts animal.miar # => "Miau!"
```

## 4. O Grande Segredo: Métodos de Classe são Métodos de Eigenclasse!

Se você já escreveu um método de classe em Ruby usando def `self.meu_metodo`, você já usou Eigenclasses sem saber.

No Ruby, classes também são objetos. Portanto, elas também têm suas próprias Eigenclasses!

Veja esse exemplo clássico:

```ruby
class Calculadora
  # Este é um método de classe comum
  def self.somar(a, b)
    a + b
  end
end
```

Ambas as formas fazem exatamente a mesma coisa: criam um método que pertence exclusivamente ao objeto `Calculadora`, e não às instâncias dele.

## Resumo para fixar

- **O que é?** Uma classe oculta, anônima e exclusiva que o Ruby cria para cada objeto individual.

- **Para que serve?** Para guardar métodos que pertencem a apenas um objeto específico (métodos singleton) ou para guardar métodos de classe.

- **Por que importa?** Porque entender isso elimina a "mágica" do Ruby, fazendo você compreender exatamente onde cada método vive na memória do sistema.

**Links para Aprofundamento:**

- [Deconstructing Eigenclasses in Ruby](https://www.rubyguides.com/2016/06/eigenclass-demystified/)
- [Ruby Inside: Visualizing Ruby's Target Eigenclass](http://www.rubyinside.com/)
- [Metaprogramação: Eigenclass em Ruby](https://www.alura.com.br/artigos/metaprogramacao-eigenclass-em-ruby?srsltid=AfmBOooJjck6FWbqn6UFv27YmMf4qD47obnHZkHwQswQRakQgWUXyn56)
