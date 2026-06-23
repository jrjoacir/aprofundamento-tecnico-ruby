# Desafio Intermediário

Dado um código legado onde múltiplos módulos alteram o comportamento do método `save`, descubra via metaprogramação (sem ler todo o arquivo) exatamente em qual módulo ou classe um método específico que foi disparado acabou sendo executado de verdade (Dica: use `Method#owner`).
