# Explicação

Quando você chama um método em Ruby (ex: `objeto.fazer_algo`), o Ruby precisa descobrir onde a implementação desse método reside. Ele faz isso seguindo uma regra estrita chamada **Ancestors Chain** (Cadeia de Ancestrais).

O caminho básico é o seguinte: o Ruby olha primeiro para a **Singleton Class** do objeto (veremos no Tópico 2). Se não achar, ele vai para a classe do objeto. Se a classe incluir módulos (`include` ou `prepend`), eles entram na fila. Se não achar, ele sobe para a superclasse, repetindo o processo até chegar em `Object`, `Kernel` e, finalmente, `BasicObject`. Se chegar ao topo e nada for encontrado, ele reinicia a busca procurando pelo método `method_missing`.

A grande sacada para o nível Sênior é entender o impacto de `include`, `prepend` e `extend`:

- `include`: Insere o módulo **logo acima** da classe atual na cadeia.
- `prepend`: Insere o módulo **logo abaixo** da classe atual na cadeia (o módulo ganha prioridade sobre a classe).
- `extend`: Adiciona os métodos do módulo na **Singleton Class** do objeto (comum para criar métodos de classe).

## Links para Aprofundamento:
- [Ruby-Doc: Module#ancestors](https://ruby-doc.org/3.4.1/Module.html#method-i-ancestors)
- [Ruby Inside](https://rubyinside.com/): Ruby Method Lookup Execution Model (Conceito clássico)
- [AppSignal Blog: Understanding Ruby's Method Lookup](https://blog.appsignal.com/2019/05/07/method-missing.html)
