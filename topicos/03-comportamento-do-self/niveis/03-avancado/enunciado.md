# Desafio Avançado

Crie um executor de blocos seguro (SandBox). Ele deve receber um bloco, alterar o `self` desse bloco para um objeto vazio (uma instância de `BasicObject`), mas deve permitir que variáveis criadas **fora** do bloco ainda possam ser lidas dentro dele através do uso de `instance_exec` passando argumentos.

# Entendendo melhor

O conceito de **Clean Room (Sala Limpa)** e o uso do `BasicObject` misturam o escopo dinâmico (`self`) com o escopo léxico (as variáveis locais ao redor do código), e isso costuma gerar confusão porque envolve regras implícitas do comportamento interno do Ruby.

Vamos abrir essa "caixa-preta" e entender exatamente o que está acontecendo por trás desse desafio, por que ele existe no mundo real e quais são esses elementos implícitos.

## O Cenário do Mundo Real (O "Porquê")

Imagine que você está construindo uma plataforma SaaS em Rails onde os seus clientes (lojistas) podem criar suas próprias regras de cupom de desconto usando código Ruby customizado.

O lojista envia um bloco de código como este:

```ruby
# Código enviado pelo usuário externo
se_dia_das_maes do
  aplicar_desconto 20
end
```

Como desenvolvedor Sênior, o seu sinal de alerta de segurança deve ligar imediatamente. Se você simplesmente rodar esse código direto no seu sistema principal, um usuário malicioso poderia enviar isto:

```ruby
# Código malicioso enviado pelo usuário externo
se_dia_das_maes do
  system("rm -rf /") # Apaga o servidor
  puts @token_secreto_da_api_da_empresa # Rouba dados
end
```

O objetivo do `Clean Room` é criar uma "caixa de areia" (Sandbox) ultra-protegida para rodar esse bloco, garantindo que ele só consiga acessar os métodos que você explicitamente permitir (como `aplicar_desconto`), mas nada do sistema principal.

## Os 3 Elementos Implícitos Revelados

Para resolver o desafio, precisamos entender os três pilares que o Ruby usa para isolar esse ambiente:

1. **A diferença entre `Object` e `BasicObject`**

Em Ruby, quase tudo herda de uma classe chamada Object. Por sua vez, `Object` inclui um módulo invisível chamado `Kernel`.
É dentro de `Kernel` que moram métodos globais como `puts`, `system`, `eval`, `exit`, `sleep`, etc.

Se o seu ambiente de isolamento herdar de `Object`, o usuário malicioso terá acesso a todo esse arsenal do `Kernel`.
A classe `BasicObject` é a mãe do `Object`. Ela é uma folha em branco absoluta. Ela quase não tem métodos (não tem `Kernel`, não tem `puts`, não tem `system`). Se você tentar rodar `system("...")` dentro de um `BasicObject`, o Ruby vai estourar um erro dizendo que o método não existe. Isso é o comportamento de "Sala Limpa".

2. **O Escopo Léxico (Bindings) vs. Escopo de Execução (`self`)**

Um bloco em Ruby (`do ... end` ou `{ ... }`) é um *closure*. Isso significa que ele carrega consigo as variáveis do lugar onde ele nasceu (escopo léxico).

O desafio pede para garantir que o bloco executado não consiga acessar as variáveis locais do escopo onde o executor foi chamado.

Veja a diferença:

```ruby
# 1. Escopo do Executor (Onde a mágica acontece)
class SandboxExecutor
  def rodar(bloco_do_usuario)
    token_ultra_secreto = "AI_KEY_999" # <- O bloco NÃO PODE ler isso!
    
    # Aqui dentro nós mudamos o self para o BasicObject
  end
end
```

Mudar o `self` para um `BasicObject` impede que o bloco acesse as variáveis de instância (`@variables`) ou métodos do executor, blindando o seu motor interno.

3. **Por que usar `instance_exec` em vez de `instance_eval?`**

Se o `BasicObject` limpa tudo, como passamos dados **seguros** para dentro do bloco? Por exemplo, o valor atual do carrinho de compras para a regra de cupom calcular o desconto?

- Se usarmos `instance_eval`, mudamos o `self`, mas não conseguimos passar argumentos para o bloco.

- Se usarmos `instance_exec`, mudamos o `self` para o `BasicObject` E conseguimos injetar variáveis seguras como argumentos do bloco.

O bloco do usuário receberia os dados assim:

```ruby
# O usuário recebe os dados seguros via argumentos do bloco (|carrinho|)
Gerador.rodar do |carrinho|
  if carrinho.total > 100
    aplicar_desconto 10
  end
end
```

## Desenho do Fluxo do Desafio

Para ficar super visual, a estrutura do seu código para resolver o desafio deve seguir este desenho:

1. Criar uma classe vazia que herda de `BasicObject` (Será o seu ambiente limpo).

2. Dentro dessa classe, você define **apenas** os métodos que o usuário tem permissão de usar (ex: `aplicar_desconto`).

3. Criar a classe `SandboxExecutor`.

4. No método `rodar` da sua Sandbox, você injeta dados sensíveis (para testar se estão protegidos), instancia seu `BasicObject`, e usa `instance_exec` para rodar o bloco do usuário dentro dele, passando apenas dados públicos/seguros.

Conseguiu visualizar os elementos que pareciam ocultos agora? O segredo gira em torno de usar o `BasicObject` para capar os métodos perigosos do `Kernel` e o `instance_exec` para isolar o `self` sem perder a habilidade de passar dados controlados.