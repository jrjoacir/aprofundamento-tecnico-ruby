# 🏛️ Guia Arquitetural: Monólitos Modulares e Engenharia de Escala

Quando uma aplicação cresce significativamente, permitir que qualquer parte do código aceda livremente a qualquer tabela da base de dados torna-se inviável. O **Monólito Modular** é uma abordagem onde o sistema permanece num único repositório, mas o código é dividido em módulos estritamente isolados através de *Engines* (motores internos), que funcionam como mini-aplicações independentes.

## 📦 1. O Básico: Anatomia de uma *Rails Engine*

- **Por que é necessário:** Em sistemas de grande escala com múltiplos times, o modelo padrão de organização do código em pastas compartilhadas gera sobreposição de responsabilidades e conflitos de nomenclatura. Isolar o código em *Engines* é indispensável para garantir a autonomia das equipes, permitindo que cada contexto de negócio evolua e execute seus testes de forma independente, sem o risco de um deploy quebrar regras de outra área.

### 🧩 Estrutura e Funcionamento

Uma *Engine* é uma aplicação em miniatura que vive dentro de uma aplicação hospedeira. Ela possui a sua própria estrutura isolada: rotas, *controllers*, *models*, *views* e migrações.

```plaintext
meu_monolito/
├── app/                  # Código global da aplicação hospedeira
├── config/routes.rb      # Rotas principais do monólito
├── engines/
│   └── vendas/
│       ├── app/
│       │   ├── controllers/
│       │   │   └── vendas/  # Namespace forçado
│       │   └── models/
│       │       └── vendas/  # Modelos isolados
│       ├── config/
│       │   └── routes.rb        # Rotas próprias da engine
│       ├── lib/
│       │   └── vendas/engine.rb  # Onde o `isolate_namespace` é ativado
│       └── vendas.gemspec   # A engine se comporta como uma Gem interna!
```

- ⚙️ **Isolamento de Namespace:** Através da configuração `isolate_namespace`, garante-se que as constantes não colidem. Uma classe `Produto` dentro do Módulo de Logística torna-se `Logistica::Produto`, isolada do resto do sistema.
- 🛤️ **Montagem de Rotas (*Mount*):** O monólito principal delega o controlo das URLs para a *Engine* através do ficheiro de rotas global, definindo um prefixo:

  ```ruby
  Rails.application.routes.draw do
    mount ModuloVendas::Engine => "/vendas"
  end
  ```

*💭 Provocação para o próximo passo:* Conseguimos isolar o código e as rotas em pastas separadas. No entanto, todas essas mini-aplicações ainda rodam sob o mesmo servidor e acessam o mesmo banco de dados. Se uma pessoa desenvolvedora do módulo de Vendas simplesmente escrever uma consulta SQL direta (como um `joins` ou um filtro) apontando para as tabelas privadas do módulo de Logística, todo esse isolamento visual não terá sido em vão? Como impedir esse acoplamento oculto na camada de dados?

## 🗄️ 2. O Intermediário: Comunicação e Isolamento de Dados

- **Por que é necessário:** O isolamento de arquivos de código é inútil se a base de dados continuar altamente acoplada. Sem regras claras de persistência, os desenvolvedores criam dependências invisíveis via banco de dados, o que causa a erosão silenciosa da arquitetura e impede qualquer tentativa futura de separar o sistema. Esta camada intermediária é necessária para impor limites lógicos ou físicos onde os dados de cada domínio residem.

### 🛡️ Estratégias de Persistência

1. **Isolamento Físico (Bases de Dados Separadas):** Cada módulo liga-se à sua própria base de dados. Garante o isolamento absoluto, mas impede transações nativas partilhadas.
2. **Isolamento Lógico (Base de Dados Partilhada com Prefixos):** Define-se um prefixo para as tabelas do módulo (ex: `vendas_clientes`).

### 🏷️ Mapeamento de Sistemas Legados

Se o sistema já possui tabelas antigas sem padrões de nomes, utilizam-se duas técnicas:

- **Mapeamento Explícito:** Define-se diretamente o nome da tabela antiga dentro do modelo da *Engine* usando `self.table_name = 'tabela_antiga'`.
- **Views de Base de Dados:** Criam-se *views* SQL que servem como "apelidos" padronizados para as tabelas antigas, protegendo o novo módulo.

### 🤖 Governação Automatizada com *Packwerk*

Para evitar que os limites lógicos sejam desrespeitados, utiliza-se a ferramenta **Packwerk**. Ela realiza uma análise estática do código no pipeline de integração contínua (CI/CD) e bloqueia o código se um módulo tentar aceder às entranhas privadas de outro sem autorização explícita.

*💭 Provocação para o próximo passo:* Agora o banco está organizado e o Packwerk impede que um módulo acesse o código privado do outro. Mas os módulos ainda precisam cooperar; o sistema de Vendas precisa saber se a Logística tem o item disponível. Se não podemos acessar as classes privadas e nem fazer consultas diretas, por onde o módulo de Vendas deve entrar para pedir essa informação com segurança, e que tipo de dado ele deve receber de volta para não quebrar as regras de privacidade?

## 🚀 3. O Avançado: APIs Públicas e a Transição para Microsserviços

- **Por que é necessário:** Para que a modularidade funcione na prática, a comunicação entre os componentes não pode ser caótica. É essencial estabelecer contratos formais que atuem como a única porta de entrada legítima de cada módulo. Sem uma API Pública bem definida e a blindagem contra falhas de rede, o sistema não consegue evoluir para uma arquitetura distribuída (microsserviços) sem trazer consigo o risco de indisponibilidade em cascata.

### 🏢 O Padrão da Portaria e Contratos

Toda a lógica interna, modelos e tabelas permanecem privados. Apenas as classes colocadas na pasta pública (ex: `app/public/`) servem de contrato oficial para os outros módulos.

- 🔑 **Uso de DTOs (*Data Transfer Objects*):** A API Pública nunca deve devolver um objeto de base de dados direto (*ActiveRecord*). Em vez disso, devolve estruturas de dados simples (como *Hashes* ou objetos imutáveis), evitando consultas extras indesejadas (*lazy loading*) e alterações indevidas por parte de quem chamou.

### 🌐 Extração para Microsserviços

Caso um módulo precise de ser extraído para um servidor próprio no futuro, o impacto no código é mínimo. Como a comunicação já era feita através de dados simples na "portaria", altera-se apenas o mecanismo de transporte interno da API Pública: em vez de executar o código na memória, ela passa a fazer uma requisição de rede (HTTP ou gRPC) para a nova URL do microsserviço.

### 🛑 Resiliência em Sistemas Distribuídos

Ao passar a comunicar por rede, novos mecanismos de proteção tornam-se obrigatórios na arquitetura para evitar que uma lentidão externa derrube todo o ecossistema:

- ⏱️ **Timeouts:** Limites de tempo rígidos para chamadas de rede e base de dados, impedindo que a lentidão de um serviço trave o monólito inteiro.
- 📉 **Rate Limiting:** Restrição da quantidade de requisições por segundo para evitar sobrecarregar o novo microsserviço.
- 🔌 **Circuit Breaker (Disjuntor):** Corta temporariamente as tentativas de comunicação se o microsserviço falhar consecutivamente, permitindo que o sistema recupere sem receber carga extra.

*💭 Provocação final:* Conseguimos criar fronteiras limpas, contratos seguros e uma infraestrutura pronta para virar microsserviço a qualquer momento. Mas a distribuição traz complexidade: depurar erros na rede é mais difícil do que ler logs em um único lugar. Diante disso, como avaliar o momento exato em que a dor do crescimento do time justifica abandonar o conforto da memória de um Monólito Modular para assumir os custos operacionais de uma arquitetura de Microsserviços?

## 📚 4. Materiais e Referências para Aprofundamento

- 📖 **Guia Oficial do Rails ([Getting Started with Engines](https://guides.rubyonrails.org/engines.html)):** A documentação técnica essencial para compreender a criação, o isolamento de namespaces e a montagem de *Rails Engines* na prática.
- 📰 **Artigo da Shopify ([Deconstructing the Monolith](https://shopify.engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity)):** Um estudo de caso detalhado sobre como uma grande plataforma de e-commerce organizou o seu ecossistema utilizando pacotes isolados dentro de um único repositório.
- 🛠️ **Ferramenta Packwerk ([Repositório GitHub](https://github.com/Shopify/packwerk)):** O guia prático da biblioteca utilizada para impor barreiras lógicas de privacidade e gerir dependências entre os módulos de forma automatizada na esteira de integração contínua (CI/CD).
- 📕 **Livro "Building Microservices" (Sam Newman):** Especialmente os capítulos sobre divisão de monólitos (*Splitting the Monolith*) e padrões de resiliência, cruciais para desenhar a transição segura para arquiteturas distribuídas.
