# Estudo para aprofundamento Tecnico em Ruby

Este repositório foi criado para minha evolução em aprofundamento técnico em Ruby. Este projeto conterá explicações de temas relevantes a este aprendizado e será conduzido com ajuda de IA (Gemini) da seguinte forma:

1. Divisão de temas a ser estudado em tópicos de estudo
2. Para cada tópico de estudos criar as seguintes seções

    2.1 Explicação completa do item de estudo listando links para aprofundamento do tema

    2.2 Elaboração de ao menos 3 exemplos do item de estudado dividido em níveis: Iniciante, Intermediário e Avançado

    2.3 Elaboração de um desafio para cada um dos níveis Iniciante, Intermediário e Avançado
4. Indicações de onde estudar mais sobre o tema

## Divisão de temas a ser estudado em tópicos

Os temas de estudo previstos são:

- **Ruby Object Model:** Entender exatamente como o Ruby busca métodos (Ancestors chain), o que são Singleton Classes e como o self se comporta em diferentes contextos.
- **Metaprogramação Avançada (o mais interessante da lista):** Não apenas usar, mas saber quando não usar. Entender define_method, method_missing, const_missing e o uso de Binding.
- **Memory Management & GC:** Estudar como o Garbage Collector do Ruby funciona (RGenGC), o que são slots e como evitar memory leaks em processos de longa duração (como workers do Sidekiq).
- **Concorrência e Paralelismo:** Entender o GVL (Global VM Lock), a diferença entre Threads, Fibers e Ractors (Ruby 3+), e como isso afeta a performance de APIs IO-bound vs CPU-bound.
