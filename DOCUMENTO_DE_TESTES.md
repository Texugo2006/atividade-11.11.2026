# Documento de Cenários de Teste e Relatório de Resultados
**Modelo de referência — Plano de Teste, Análise de Risco, Casos de Teste e Relatório de Validação**

---

## 1. Identificação

| Campo | Preenchimento |
| :--- | :--- |
| **Projeto / Sistema** | Pet Shop Patas & Pelos – Digital Horizon |
| **Competência Avaliada (SA)** | **"Automatizando testes de funcionalidades da aplicação utilizando ferramentas compatíveis com aplicações web. (SA)"** |
| **Responsável pelo teste** | Desenvolvedor Mobile Júnior (Equipe Digital Horizon) |
| **Data de elaboração** | 11/11/2026 |
| **Versão do documento** | 1.0 |
| **Ambiente de teste** | Flutter SDK 3.22.x, Dart 3.5.x, Node.js 24.x, Cypress v13.17.0, Google Chrome (Web), Emulador Android, REST API Mock (`json-server` :3000), Hive Local Storage |

---

## 2. Plano de Teste

### 2.1. Objetivo
Garantir a integridade funcional, confiabilidade das regras de negócio, conformidade com a LGPD (separação de dados públicos e sensíveis), consumo resiliente de APIs RESTful externas e internas, persistência local com Hive, conformidade com os padrões de Programação Orientada a Objetos (POO) / Clean Architecture e responsividade universal da interface visual do aplicativo Pet Shop Patas & Pelos, **automatizando testes de funcionalidades da aplicação utilizando ferramentas compatíveis com aplicações web (SA)**.

### 2.2. Escopo

* **O que ENTRA nesta rodada de testes:**
  * **Modelos e Entidades de Domínio:** Serialização, desserialização JSON, polimorfismo (`ProductModel is Product`) e tratamento defensivo de tipos nulos e conversões numéricas.
  * **Casos de Uso (Clean Architecture):** Operações completas de CRUD (`GetProducts`, `CreateProduct`, `UpdateProduct`, `DeleteProduct`) e manipulação de carrinho de compras.
  * **Serviços de API Web:** Integração com a Dog API (`dog.ceo`), extração do slug da raça, tradução para português e algoritmo de geração dinâmica de 3 dicas especializadas (energia, pelagem e saúde).
  * **Persistência Local e Governança de Dados (Hive):** Armazenamento de agendamentos de banho/tosa, perfil do tutor e itens do carrinho localmente no dispositivo.
  * **Resiliência e Detecção de Plataforma:** Conectividade dinâmica do `json-server` (`localhost` para Web e `10.0.2.2` para Android).
  * **Qualidade de Interface e Responsividade:** Remoção de banners técnicos de depuração e ajuste adaptativo em diferentes tamanhos de tela.

* **O que NÃO ENTRA nesta rodada de testes:**
  * Gateway de pagamento bancário em produção com processamento real de cartões (simulado localmente).
  * Teste de estresse de infraestrutura com mais de 10.000 requisições simultâneas.

### 2.3. Estratégia e Técnicas Utilizadas
* **Automação com Ferramentas Compatíveis com Aplicações Web (`flutter test` / `Dart Test`):** Execução de testes de funcionalidades automatizados utilizando o test runner nativo do Flutter/Dart, que compila para JavaScript/WebAssembly e executa assincronamente com total suporte ao ecossistema web.
* **Teste com Simulação de Requisições Web (`MockClient`):** Utilização da biblioteca `package:http/testing.dart` para emular requisições HTTP RESTful de aplicações web, validando respostas 200 (sucesso) e 500 (falha de rede) sem depender de conexões externas.
* **Teste Funcional (Caixa-Preta):** Validação de ponta a ponta dos fluxos de cadastro, edição, exclusão, agendamento e compra.
* **Teste de Valores-Limite e Partição de Equivalência:** Entradas nulas, strings vazias, números decimais e inteiros em campos monetários.
* **Teste de Responsividade e Usabilidade:** Validação de renderização sem *overflow* em diferentes densidades de pixels e resoluções.

### 2.4. Critérios de Entrada
* Código-fonte compilando sem erros impeditivos no Flutter 3.22+.
* Servidor mock `json-server` configurado com a base `db.json` com produtos, serviços e promoções.
* Banco de dados local Hive inicializado e registrado no ciclo de vida do app.
* Suíte de testes unitários automatizados implementada na pasta `test/`.

### 2.5. Critérios de Saída
* 100% dos testes unitários automatizados executados e aprovados (`All tests passed!`).
* 0 defeitos bloqueantes ou de severidade alta abertos.
* Taxa de aprovação mínima de 100% dos casos planejados.
* Interface 100% limpa, sem mensagens técnicas ou banners de depuração visíveis para o cliente.

### 2.6. Recursos e Cronograma

| Atividade | Responsável | Início | Fim |
| :--- | :--- | :---: | :---: |
| **Elaboração dos casos de teste** | QA / Dev Mobile | 05/11/2026 | 06/11/2026 |
| **Execução e automação dos testes** | QA / Dev Mobile | 11/11/2026 | 11/11/2026 |
| **Elaboração do relatório de validação** | QA / Dev Mobile | 11/11/2026 | 11/11/2026 |

---

## 3. Análise de Risco

| ID | Risco Identificado | Probabilidade | Impacto | Prioridade | Estratégia de Mitigação |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **R01** | Inconsistência de tipagem JSON (preço retornado como inteiro pelo backend derrubando o app por erro de cast `int is not double`). | Alta | Alto | **Alta** | Implementar conversão defensiva no factory `ProductModel.fromJson` (`(json['price'] as num).toDouble()`) e cobrir com testes unitários. |
| **R02** | Vazamento de dados sensíveis e violação de privacidade (LGPD) por armazenamento de dados de clientes na API pública. | Alta | Crítico | **Alta** | Isolar estritamente dados sensíveis (perfil, pet e agendamentos) no Hive local do dispositivo, sem tráfego na API REST aberta. |
| **R03** | Indisponibilidade da API externa Dog API ou falha de conexão travando a renderização da aba de curiosidades. | Alta | Médio | **Alta** | Implementar bloco `try-catch` resiliente que retorna `null` seguro e aciona dicas estáticas padrão de hidratação e vacinação como fallback. |
| **R04** | Falha de resolução de loopback de rede ao rodar no Flutter Web vs Emulador Android (`localhost` vs `10.0.2.2`). | Alta | Alto | **Alta** | Criar detecção dinâmica de plataforma no `constants.dart` (`kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'`). |
| **R05** | Quebra visual de layout (*RenderFlex overflow*) em dispositivos com larguras de tela diferentes (mobile, tablet, desktop). | Média | Médio | **Média** | Utilizar `SliverGridDelegateWithMaxCrossAxisExtent` com tamanho controlado de cards e `ConstrainedBox` centralizado em formulários. |

---

## 4. Casos de Teste

| ID | Título | Pré-condição | Passos | Dado de entrada | Resultado Esperado | Prioridade | Risco Relacionado |
| :---: | :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **CT01** | Desserialização de JSON de Produto | JSON válido com dados de produto | 1. Executar `ProductModel.fromJson(mockJson)` 2. Validar campos mapeados | Objeto JSON com `id`, `name`, `price: 120.50`, etc. | Model instanciado com todos os atributos preenchidos corretamente | Alta | R01 |
| **CT02** | Serialização de Produto para JSON | Instância de `ProductModel` criada | 1. Invocar `model.toJson()` 2. Verificar chaves e valores retornados | Objeto `ProductModel` instanciado | `Map<String, dynamic>` com chaves e tipos esperados para envio via POST/PUT | Alta | R01 |
| **CT03** | Comprovação de Polimorfismo e Herança | Classe `ProductModel` implementada | 1. Instanciar `ProductModel` 2. Verificar se herda de `Product` | Objeto `ProductModel` | `model is Product` retorna verdadeiro comprovando POO em Dart | Média | R01 |
| **CT04** | Tratamento Defensivo de Nulos e Coerção Numérica | JSON com campos numéricos inteiros e campos ausentes | 1. Passar JSON com `price: 100` (int) e valores opcionais nulos 2. Executar `ProductModel.fromJson` | `{'price': 100, 'breed': null}` | Conversão automática para `double` (100.0) sem exceção de cast e fallback para strings vazias | Alta | R01 |
| **CT05** | Obtenção de Produtos via UseCase `GetProducts` | Repositório mockado com 2 produtos | 1. Instanciar `GetProducts(mockRepo)` 2. Executar `call()` | N/A | Retornar lista contendo exatamente os 2 produtos mockados | Alta | R01 |
| **CT06** | Cadastro de Produto via UseCase `CreateProduct` | Repositório em memória inicializado | 1. Criar novo `Product` 2. Invocar `CreateProduct.call(product)` | Produto "Bifinho Canino", R$ 8.90 | Produto persistido no repositório e recuperável na listagem | Alta | R01 |
| **CT07** | Atualização de Produto via UseCase `UpdateProduct` | Produto existente com ID "p1" | 1. Modificar preço e nome 2. Invocar `UpdateProduct.call(updatedProduct)` | Produto "Ração Modificada", R$ 99.00 | Dados atualizados no repositório mantendo o mesmo ID | Alta | R01 |
| **CT08** | Exclusão de Produto via UseCase `DeleteProduct` | Produto existente no repositório | 1. Invocar `DeleteProduct.call("p1")` 2. Consultar repositório | ID "p1" | Produto removido com sucesso; contagem de produtos decrementada | Alta | R01 |
| **CT09** | Tradução de Raça da Dog API em Português | Slug presente no dicionário de traduções | 1. Invocar `DogApiService.formatBreedName('mountain-bernese')` | `'mountain-bernese'` | Retorna `'Boiadeiro Bernês (Bernese Mountain Dog)'` formatado | Média | R03 |
| **CT10** | Formatação de Raça Não Catalogada (Fallback) | Slug composto não listado no dicionário | 1. Invocar `DogApiService.formatBreedName('hound-ibizan')` | `'hound-ibizan'` | Reverte slug e capitaliza palavras retornando `'Ibizan Hound'` | Média | R03 |
| **CT11** | Geração Contextual de 3 Dicas Especializadas | Slug de raça específica identificado | 1. Invocar `DogApiService.generateTipsForBreed('bulldog-french', ...)` | Raça braquicefálica | Retorna lista de 3 dicas específicas contendo recomendação respiratória e cuidados no calor | Alta | R03 |
| **CT12** | Consumo HTTP da Dog API com Sucesso | Servidor mock HTTP retornando 200 e status success | 1. Configurar `MockClient` com JSON da Dog API 2. Executar `getRandomDogInfo()` | Resposta 200 com URL de imagem | Objeto `DogInfo` instanciado com URL da foto, raça e 3 dicas preenchidas | Alta | R03 |
| **CT13** | Resiliência contra Erros de Rede na Dog API | Servidor mock HTTP retornando código 500 | 1. Configurar `MockClient` com HTTP 500 2. Executar `getRandomDogInfo()` | Erro de servidor / timeout | Retorna `null` de forma segura sem crashar o aplicativo | Alta | R03 |
| **CT14** | Persistência Segura de Dados no Hive (LGPD) | Hive inicializado localmente | 1. Salvar agendamento via `saveAppointment` 2. Recuperar via `getAppointments` | Agendamento de Banho & Tosa para "Rex" | Dados recuperados com sucesso do armazenamento local sem envio para rede | Alta | R02 |
| **CT15** | Detecção Dinâmica de Plataforma para Conexão REST | App executado no Chrome Web | 1. Ler constante `kBaseUrl` no navegador | Ambiente Web | URL aponta para `http://localhost:3000` permitindo conexão sem erro de socket | Alta | R04 |
| **CT16** | Responsividade e Ausência de Notificações Técnicas | Tela inicial aberta em qualquer resolução | 1. Acessar tela inicial e aba de curiosidades 2. Verificar ausência de banners amarelos e layout | Resolução mobile / desktop | Grade de produtos adaptada, sem overflow e sem banners técnicos de API na UI | Média | R05 |
| **CT-CY01** | Teste E2E Cypress da API REST de Produtos | Servidor `json-server` online em `:3000` | Requisição `GET http://localhost:3000/products` | Endpoint REST `/products` | Status 200, array de 12 produtos com propriedades de id, nome, preço e marca | Alta | R01 |
| **CT-CY02** | Teste E2E Cypress da API REST de Serviços | Servidor `json-server` online em `:3000` | Requisição `GET http://localhost:3000/services` | Endpoint REST `/services` | Status 200, array contendo banho e tosa e consulta veterinária | Alta | R01 |
| **CT-CY03** | Teste E2E Cypress da API REST de Promoções | Servidor `json-server` online em `:3000` | Requisição `GET http://localhost:3000/promotions` | Endpoint REST `/promotions` | Status 200, cupons ativos disponíveis | Média | R01 |
| **CT-CY04** | Teste E2E Cypress da Dog API Externa | Conexão com a web ativa | Requisição `GET https://dog.ceo/api/breeds/image/random` | Dog API externa | Status 200, campo status "success" e URL de imagem válida | Alta | R03 |
| **CT-CY05** | Teste E2E Cypress da API ViaCEP | Conexão com a web ativa | Requisição `GET https://viacep.com.br/ws/01001000/json/` | ViaCEP | Status 200, CEP, logradouro e cidade retornados | Média | R04 |

---

## 5. Execução dos Testes

| ID do Caso | Data Execução | Resultado Obtido | Status | Defeito (ID) | Observações |
| :---: | :---: | :--- | :---: | :---: | :--- |
| **CT01** | 11/11/2026 | Modelo desserializado com todos os atributos idênticos ao JSON. | **Aprovado** | Nenhum | Executado via `flutter test`. |
| **CT02** | 11/11/2026 | Map gerado corretamente com tipos primitivos válidos. | **Aprovado** | Nenhum | Executado via `flutter test`. |
| **CT03** | 11/11/2026 | Expressão `model is Product` avaliada como `true`. | **Aprovado** | Nenhum | Garante abstração e herança em Dart. |
| **CT04** | 11/11/2026 | Inteiro 100 convertido para 100.0 e nulos tratados sem erro. | **Aprovado** | Nenhum | Blindagem contra quebra de tipagem. |
| **CT05** | 11/11/2026 | Lista com 2 produtos retornada com sucesso pelo caso de uso. | **Aprovado** | Nenhum | Clean Architecture validada. |
| **CT06** | 11/11/2026 | Produto adicionado ao repositório mock e consultado. | **Aprovado** | Nenhum | Fluxo de criação validado. |
| **CT07** | 11/11/2026 | Produto com ID existente atualizado corretamente. | **Aprovado** | Nenhum | Fluxo de alteração validado. |
| **CT08** | 11/11/2026 | Produto removido e lista final sem o elemento. | **Aprovado** | Nenhum | Fluxo de exclusão validado. |
| **CT09** | 11/11/2026 | Retornou `'Boiadeiro Bernês (Bernese Mountain Dog)'`. | **Aprovado** | Nenhum | Dicionário de tradução validado. |
| **CT10** | 11/11/2026 | Retornou `'Ibizan Hound'` a partir de `'hound-ibizan'`. | **Aprovado** | Nenhum | Algoritmo de fallback validado. |
| **CT11** | 11/11/2026 | Retornou 3 dicas específicas para a anatomia do Buldogue. | **Aprovado** | Nenhum | Dicas dinâmicas validadas. |
| **CT12** | 11/11/2026 | Objeto `DogInfo` gerado com sucesso via mock HTTP. | **Aprovado** | Nenhum | Integração com Dog API validada. |
| **CT13** | 11/11/2026 | Retornou `null` defensivamente sob erro HTTP 500. | **Aprovado** | Nenhum | Resiliência comprovada. |
| **CT14** | 11/11/2026 | Agendamento persistido e recuperado do box do Hive. | **Aprovado** | Nenhum | Isolamento LGPD comprovado. |
| **CT15** | 11/11/2026 | URL dinâmica resolveu `localhost:3000` no Chrome Web. | **Aprovado** | Nenhum | Conectividade cross-platform ok. |
| **CT16** | 11/11/2026 | Grid adaptativo perfeito e avisos de depuração removidos. | **Aprovado** | Nenhum | Interface limpa e responsiva. |
| **CT-CY01** | 11/11/2026 | Cypress validou endpoint `/products` com 12 produtos e chaves íntegras. | **Aprovado** | Nenhum | Executado via `npx cypress run` (145ms). |
| **CT-CY02** | 11/11/2026 | Cypress validou `/services` com banho, tosa e consulta veterinária. | **Aprovado** | Nenhum | Executado via `npx cypress run` (57ms). |
| **CT-CY03** | 11/11/2026 | Cypress validou `/promotions` e cupons ativos da loja. | **Aprovado** | Nenhum | Executado via `npx cypress run` (47ms). |
| **CT-CY04** | 11/11/2026 | Cypress validou Dog API pública externa retornando foto e status success. | **Aprovado** | Nenhum | Executado via `npx cypress run` (489ms). |
| **CT-CY05** | 11/11/2026 | Cypress validou ViaCEP retornando dados de entrega válidos. | **Aprovado** | Nenhum | Executado via `npx cypress run` (798ms). |

---

## 6. Relatório de Resultados (Resumo Executivo)

### 6.1. Métricas Gerais

| Indicador | Valor |
| :--- | :---: |
| **Total de casos planejados** | 21 (16 unitários/funcionais + 5 E2E Cypress) |
| **Total de casos executados** | 21 |
| **Aprovados** | 21 |
| **Reprovados** | 0 |
| **Bloqueados** | 0 |
| **Taxa de sucesso (%)** | **100%** |

### 6.2. Principais Defeitos Encontrados e Corrigidos Durante o Ciclo

| ID Defeito | Descrição | Severidade | Caso de Teste Relacionado | Status |
| :---: | :--- | :---: | :---: | :---: |
| **DEF-01** | `ClientException: Failed to fetch` no Flutter Web devido ao endereço `10.0.2.2` exclusivo para Android. | Alta | CT15 | **Corrigido** (implementada detecção dinâmica em `constants.dart`). |
| **DEF-02** | Links de imagem quebrados (*placeholder 404*) exibindo caixa cinza com "X". | Média | CT01, CT16 | **Corrigido** (substituídos por imagens Unsplash com CORS aberto e `errorBuilder`). |
| **DEF-03** | Banners amarelos técnicos e textos de depuração de API poluindo a interface do usuário. | Baixa | CT16 | **Corrigido** (removidos da UI, mantendo a tela visualmente elegante). |
| **DEF-04** | Dicas do especialista na aba do cão eram estáticas e não acompanhavam a raça sorteada. | Média | CT11 | **Corrigido** (criado algoritmo de geração dinâmica de 3 dicas por raça). |

### 6.3. Riscos Residuais
* **Risco de Conectividade do Usuário Final:** Como o catálogo e as fotos dependem de conexão com a internet (ou com o `json-server` local), aparelhos completamente offline verão as mensagens de fallback implementadas. O risco residual é considerado **Baixo** e aceitável para o estágio atual do projeto.

### 6.4. Conclusão e Recomendação
> **Parecer Final:** **SISTEMA APROVADO PARA PRODUÇÃO / ENTREGA FINAL.**  
> **Justificativa:** O aplicativo atingiu 100% de aprovação nos testes planejados, atendeu a todos os requisitos arquiteturais e pedagógicos (Clean Architecture, POO em Dart, separação de dados públicos vs sensíveis com Hive, consumo de múltiplas APIs RESTful) e possui interface polida, responsiva e livre de inconsistências visuais.

---

## 7. Normalização e Aprovação

| Papel | Nome | Assinatura / Data |
| :--- | :--- | :---: |
| **Elaborado por (QA / Testador)** | Desenvolvedor Mobile Júnior | 11/11/2026 |
| **Revisado por** | Arquiteto de Software – Digital Horizon | 11/11/2026 |
| **Aprovado por** | Líder Técnico da Campanha Local | 11/11/2026 |
