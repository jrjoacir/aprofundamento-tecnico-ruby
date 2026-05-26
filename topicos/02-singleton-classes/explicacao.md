# Explicação

Em Ruby, estruturas como "métodos de classe" na verdade não existem de forma isolada. Classes não podem ter métodos que instâncias não têm, a menos que usem um truque de arquitetura: a Singleton Class (também conhecida como Eigenclass ou Metaclass).

Cada objeto em Ruby (e lembre-se, classes também são objetos!) possui uma classe oculta, exclusiva para si. Quando você define um método diretamente em um objeto específico (`def objeto.metodo`),esse método é guardado na Singleton Class desse objeto.

No caso de métodos de classe (`def Self.meu_metodo`), o que está acontecendo é que o método está sendo adicionado à Singleton Class do objeto Class.

```
[Instância de User] -> [Singleton Class de User] -> [Classe User] -> [Singleton Class de Class] -> [Classe Class]
```

**Links para Aprofundamento:**

- [Deconstructing Eigenclasses in Ruby](https://www.rubyguides.com/2016/06/eigenclass-demystified/)
- [Ruby Inside: Visualizing Ruby's Target Eigenclass](http://www.rubyinside.com/)
