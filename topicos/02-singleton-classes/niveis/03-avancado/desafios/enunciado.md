# Desafio Avançado

Crie um método macro chamado `class_attribute` (semelhante ao do ActiveSupport do Rails). Quando declarado na classe pai, ele deve gerar métodos de leitura e escrita de classe. Se uma classe filha herdar dessa classe pai, ela deve herdar o valor atual, mas se a classe filha alterar o valor, a alteração não deve afetar a classe pai. Use Singleton Classes para isolar o estado.
