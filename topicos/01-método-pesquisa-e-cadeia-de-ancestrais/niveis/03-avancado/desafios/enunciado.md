# Desafio Avançado

Implemente um sistema de *Hooks/Callbacks* simples (estilo `before_action` do Rails) usando apenas `prepend` dinâmico. Sempre que uma classe herdar de sua classe base `BaseController`, ela deve injetar dinamicamente um módulo na frente (`prepend`) para interceptar a execução de determinados métodos e rodar uma validação antes deles.
