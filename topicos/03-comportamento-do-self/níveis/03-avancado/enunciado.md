# Desafio Avançado

Crie um executor de blocos seguro (SandBox). Ele deve receber um bloco, alterar o `self` desse bloco para um objeto vazio (uma instância de `BasicObject`), mas deve permitir que variáveis criadas **fora** do bloco ainda possam ser lidas dentro dele através do uso de `instance_exec` passando argumentos.
