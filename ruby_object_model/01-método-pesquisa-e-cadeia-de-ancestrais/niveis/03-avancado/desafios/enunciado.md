# Desafio Avançado

Implemente um sistema de *Hooks/Callbacks* simples (estilo `before_action` do Rails) usando apenas `prepend` dinâmico. Sempre que uma classe herdar de sua classe base `BaseController`, ela deve injetar dinamicamente um módulo na frente (`prepend`) para interceptar a execução de determinados métodos e rodar uma validação antes deles.

# Observações

O desafio feito com auxílio do Gemini tem como base alguns conceitos importantes:

- Método [**inherited**](https://ruby-doc.org/3.4.1/Class.html#method-i-inherited) da classe [**Class**](https://ruby-doc.org/3.4.1/Class.html) é chave para a construção do desafio. Este método é invocado toda vez que uma classe herda de outra tendo a subclasse como parâmetro.

- Já o método [**instance_variable_set**](https://ruby-doc.org/3.4.1/Object.html#method-i-instance_variable_set) da classe [**Object**](https://ruby-doc.org/3.4.1/Object.html) é o método que define as variáveis de instância de uma classe instanciada.

- O método [**define_method**](https://ruby-doc.org/3.4.1/Module.html#method-i-define_method) da classe [**Module**](https://ruby-doc.org/3.4.1/Module.html) define em tempo real um método para a classe informada.