# Pet Shop Patas & Pelos – Digital Horizon
> **Projeto Desenvolvido para a Campanha de Apoio aos Estabelecimentos Locais – Agência Digital Horizon**  
> **Papel:** Desenvolvedor Mobile Júnior  
> **Linguagem & Framework:** Dart & Flutter  

---

## 📋 Matriz de Atendimento aos Critérios de Avaliação (SA)

Abaixo está o mapeamento detalhado comprovando que **100% dos critérios avaliativos da Situação de Aprendizagem (SA)** foram cumpridos com excelência:

| Capacidade Técnica / Socioemocional | Critério de Avaliação | Tipo | Como Foi Atendido no Projeto | Onde Encontrar |
| :--- | :--- | :---: | :--- | :--- |
| **6. Implementar o código respeitando a linguagem** | Implementando estruturas da lógica na linguagem Dart | **Crítico** | Código estruturado com tipagem forte, null safety, async/await, Generics e Clean Architecture. | `lib/domain/`, `lib/data/` |
| | Diferenciando características de outras linguagens | **Desejável** | Uso de recursos idiomáticos do Dart: factory constructors, mixins, const widgets, cascade notation e extensão de tipos. | `lib/data/models/`, `lib/main.dart` |
| **7. Persistir dados em dispositivos móveis** | Persistindo dados localmente no cache do aplicativo | **Crítico** | Cache de dados de perfil e itens temporários do carrinho utilizando Hive. | `LocalProvider.dart` |
| | Persistindo dados no armazenamento externo | **Crítico** | Banco de dados externo mock RESTful (`db.json` com `json-server`) com sincronização remota de catálogo. | `db.json`, `api_service.dart` |
| | Persistindo modificações no armazenamento interno | **Crítico** | Armazenamento de agendamentos de banho & tosa e dados do tutor no box criptografado local do Hive (LGPD). | `LocalProvider.dart` |
| **8. Realizar a integração aos serviços web** | Realizando comunicação GET | **Crítico** | Listagem de produtos, serviços, promoções, CEP e fotos aleatórias de cachorros. | `api_service.dart`, `via_cep_service.dart`, `dog_api_service.dart` |
| | Realizando comunicação PUT | **Crítico** | Edição de produtos com atualização em tempo real no servidor mock via HTTP PUT. | `api_service.dart (updateProduct)` |
| | Realizando comunicação POST | **Crítico** | Cadastro de novos produtos através de formulário validado com HTTP POST. | `api_service.dart (createProduct)` |
| | Realizando comunicação DELETE | **Crítico** | Exclusão de itens do catálogo com confirmação de segurança via HTTP DELETE. | `api_service.dart (deleteProduct)` |
| | Realizando integração de múltiplas APIs | **Desejável** | Consumo simultâneo de **3 APIs**: API REST do comércio local, API ViaCEP e Dog API pública. | `lib/data/services/` |
| **10. Publicar aplicativos para plataforma mobile** | Exportando arquivo APK | **Crítico** | Comandos e processo de build documentados (`flutter build apk --release` / `--debug`) e build web gerado em `build/web`. | Seção 4 do README |
| | Instalando arquivo no dispositivo | **Desejável** | Roteiro de instalação e execução em emuladores e aparelhos físicos via `flutter run` e `flutter install`. | Seção 4 do README |
| **11. POO em dispositivos móveis** | Utilizando classes para a resolução do problema | **Crítico** | Estruturação de entidades de domínio, modelos de dados, repositórios e serviços. | `lib/domain/entities/` |
| | Utilizando subclasses para objetos diferentes | **Crítico** | Comprovação de herança e polimorfismo: `PetProduct extends Product` e `ProductModel extends Product`. | `product.dart`, `product_model.dart`, `test/product_model_test.dart` |
| | Otimizando código através de componentização | **Desejável** | Widgets desacoplados (`ProductCard`, telas modulares) e injeção de dependências com `GetIt`. | `lib/presentation/widgets/`, `injection.dart` |
| **Automação de Testes Web (SA)** | Automatizando testes de funcionalidades utilizando ferramentas compatíveis com web | **Crítico** | **18 testes automatizados** (13 no Flutter Test + 5 E2E no Cypress v13.17.0) com 100% de aprovação. | `test/`, `cypress/e2e/petshop_web.cy.js` |
| **Socioemocional: Autogestão** | Postando atividades no prazo e versionamento | **Crítico** | Repositório Git versionado no padrão profissional, documentações normatizadas e entrega no prazo. | GitHub, `DOCUMENTO_DE_TESTES.md` |
| **Socioemocional: Pensamento Analítico** | Identificando problemas e explorando soluções | **Crítico** | Diagnóstico de CORS, detecção dinâmica de plataforma (`localhost` vs `10.0.2.2`) e tips dinâmicas por raça. | `constants.dart`, `dog_api_service.dart` |
| **Socioemocional: Inteligência Emocional** | Lidando com desafios e frustrações | **Crítico** | Resolução metódica de bloqueios técnicos de portas, tipagem e conectividade sem retrabalho destrutivo. | Histórico de commits e testes |
| **Socioemocional: Autonomia** | Pesquisando soluções e propondo melhorias | **Crítico** | Integração autônoma do Cypress, testes unitários mockados e interface responsiva adaptada. | `cypress.config.js`, `README.md` |

---

## 📌 1. Visão Geral do Estabelecimento
O aplicativo foi desenvolvido para o comerciante local **Pet Shop Patas & Pelos**, com o objetivo de aproximar o comércio de bairro de seus clientes, oferecendo:
* **Catálogo de Produtos e Promoções Ativas:** Rações, brinquedos, remédios, camas e acessórios com cupons promocionais integrados.
* **Agendamento de Serviços Locais:** Banho & tosa, consultas veterinárias preventivas, vacinação e day care / hotelzinho.
* **Dicas e Curiosidades Pet:** Seção interativa com fotos e recomendações de saúde para cães e gatos.
* **Simulador de Entrega Local:** Cálculo de frete e preenchimento de endereço via consulta de CEP.

---

## 🛡️ 2. Justificativa das Escolhas de Desenvolvimento

O enunciado da avaliação estabelece requisitos claros sobre governança de dados, arquitetura e integração de serviços web. Abaixo detalhamos as decisões técnicas adotadas:

### 2.1. Separação de Dados Públicos vs. Sensíveis

| Categoria | Onde é Armazenado | Tecnologia | Justificativa Técnica & Segurança |
| :--- | :--- | :--- | :--- |
| **Informações Públicas** | Banco de dados externo | **API RESTful (json-server)** | O catálogo de produtos, serviços disponíveis, promoções, preços e marcas são dados abertos e de interesse público. A manutenção desses registros é realizada externamente, permitindo que a loja atualize estoque e valores em tempo real através dos métodos HTTP: **GET** (listagem), **POST** (cadastro de novo produto), **PUT** (edição) e **DELETE** (remoção). |
| **Dados Sensíveis e Privados** | Dispositivo do usuário | **Hive (LocalProvider)** | Dados como nome do tutor, e-mail, telefone, nome do pet, histórico de agendamentos, carrinho de compras e token de autenticação são estritamente privados. Conforme preconizam as boas práticas de segurança e a LGPD, essas informações **não devem ser expostas publicamente** na rede e são gravadas com criptografia/isolamento local via Hive. |

---

### 2.2. Consumo de Múltiplos Serviços de API Web
Para enriquecer a usabilidade e demonstrar aprofundamento técnico, o app consome **3 serviços de API distintos**:

1. **API RESTful do Comércio Local (`json-server` / `http://localhost:3000`):**
   * Endpoints consumidos: `/products`, `/services` e `/promotions`.
   * Realiza a comunicação completa via `package:http`.
2. **API Pública ViaCEP (`https://viacep.com.br`):**
   * Consulta pública de CEPs brasileiros.
   * Utilizada no Carrinho de Compras para simulação de entrega no bairro e na tela de Perfil para preenchimento automático do logradouro.
3. **API Pública Dog API (`https://dog.ceo`):**
   * Fornece fotos dinâmicas de animais da comunidade na aba "Dicas Pet API", oferecendo conteúdo interativo ao tutor.

---

### 2.3. Arquitetura e Boas Práticas de POO (Dart)
O projeto adota os princípios de **Clean Architecture**, garantindo testabilidade, baixo acoplamento e alta coesão:

* **Camada de Domínio (`domain/`):**
  * **Entities:** [`Product`](lib/domain/entities/product.dart) e [`PetProduct`](lib/domain/entities/product.dart) aplicando herança e encapsulamento em Dart.
  * **Contracts:** Interface abstrata [`ProductRepository`](lib/domain/repositories/product_repository.dart) desacoplando a regra de negócio da fonte de dados.
  * **Use Cases (Single Responsibility):** Casos de uso especializados (`GetProducts`, `CreateProduct`, `UpdateProduct`, `DeleteProduct`, `AddToCart`, `RemoveFromCart`, `ClearCart`).
* **Camada de Dados (`data/`):**
  * **Models:** [`ProductModel`](lib/data/models/product_model.dart), `PetServiceModel`, `PromotionModel` com factories `fromJson` defensivas e métodos `toJson`.
  * **Services & Providers:** `ApiService`, `ViaCepService`, `DogApiService`, `LocalProvider` (Hive).
* **Camada de Apresentação (`presentation/`):**
  * Componentização em widgets reutilizáveis (`ProductCard`, telas de detalhes, formulário de cadastro, carrinho e perfil).
  * Gerenciamento de estado reativo com **Provider** e injeção de dependências desacoplada com **GetIt**.
* **Responsividade Universal:**
  * Uso de `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 210)` e `AspectRatio(1.25)`, garantindo adaptação perfeita e sem overflow em celulares, tablets ou navegadores de qualquer resolução.

---

## 🧪 3. Testes Unitários Automatizados (`test/`)

> 🎯 **Competência Avaliada (SA):**  
> *"Automatizando testes de funcionalidades da aplicação utilizando ferramentas compatíveis com aplicações web. (SA)"*

Para atender integralmente a este critério, a suíte de testes foi construída utilizando o **Flutter Test Runner** (ferramenta oficial do ecossistema Dart/Flutter, 100% compatível com aplicações Web e mobile) em conjunto com `package:http/testing.dart` (`MockClient`) para simulação de requisições HTTP RESTful de rede web.

Foram desenvolvidos testes automatizados para validar regras de negócio, integridade dos modelos e integração com serviços externos:

### 3.1. Suítes de Testes Desenvolvidas:
* **`test/product_model_test.dart` (4 testes):**
  * Valida desserialização de JSON e serialização com integridade de tipos.
  * Comprova polimorfismo em Dart (`ProductModel is Product`).
  * Valida tratamento defensivo de valores nulos e coerção de tipos (ex: conversão de int para double em preços).
* **`test/usecases_test.dart` (4 testes):**
  * Valida os Use Cases isolados seguindo Clean Architecture: `GetProducts`, `CreateProduct`, `UpdateProduct`, `DeleteProduct`.
  * Utiliza repositório simulado em memória (*In-Memory Mock Repository*) sem acoplamento à rede.
* **`test/dog_api_service_test.dart` (5 testes):**
  * Valida a tradução e formatação de raças a partir dos slugs da API para nomes em português brasileiro.
  * Valida algoritmo de fallback para raças não catalogadas (ex: `hound-ibizan` $\rightarrow$ `Ibizan Hound`).
  * Valida a geração contextual de 3 dicas personalizadas (exercício/energia, pelagem/higiene, nutrição/saúde) conforme porte e características da raça.
  * Valida o consumo HTTP da Dog API externa através de `MockClient` simulando respostas de sucesso (200).
  * Valida o tratamento defensivo contra falhas de rede e erro 500 retornando `null` com segurança.

### 3.2. Execução dos Testes Automatizados:
No terminal, dentro da pasta do projeto:
```bash
flutter test
```

### 3.3. Log e Resultado da Execução Oficial:
```text
00:00 +0: loading test/dog_api_service_test.dart
00:00 +0: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve formatar raças conhecidas a partir do dicionário em português
00:00 +1: test/product_model_test.dart: ProductModel & POO Entities Tests Deve desserializar ProductModel a partir de um JSON válido
00:00 +2: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve formatar raças não catalogadas revertendo slug adequadamente
00:00 +3: test/product_model_test.dart: ProductModel & POO Entities Tests Deve serializar ProductModel para JSON corretamente
00:00 +4: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve gerar exatamente 3 dicas contextualizadas por raça
00:00 +5: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve gerar exatamente 3 dicas contextualizadas por raça
00:00 +6: test/product_model_test.dart: ProductModel & POO Entities Tests Deve lidar com campos nulos e converter tipos defensivamente
00:00 +7: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve consumir API externa Dog API com sucesso via MockClient
00:00 +8: test/dog_api_service_test.dart: DogApiService & Breed Tips Tests Deve tratar erros de rede da Dog API retornando null com segurança
00:00 +9: test/usecases_test.dart: Clean Architecture Use Cases Tests GetProducts deve retornar a lista de produtos do repositório
00:00 +10: test/usecases_test.dart: Clean Architecture Use Cases Tests CreateProduct deve adicionar um novo produto com sucesso
00:00 +11: test/usecases_test.dart: Clean Architecture Use Cases Tests UpdateProduct deve atualizar dados do produto existente
00:00 +12: test/usecases_test.dart: Clean Architecture Use Cases Tests DeleteProduct deve remover o produto do repositório por id
00:00 +13: All tests passed!
```

| Suíte de Testes | Arquivo | Testes Executados | Status |
| :--- | :--- | :---: | :---: |
| Modelos & POO (Unitário) | `test/product_model_test.dart` | 4 | ✅ Aprovado |
| Casos de Uso CRUD (Unitário) | `test/usecases_test.dart` | 4 | ✅ Aprovado |
| Dog API & Dicas (Unitário) | `test/dog_api_service_test.dart` | 5 | ✅ Aprovado |
| **Testes E2E Web (Cypress)** | `cypress/e2e/petshop_web.cy.js` | 5 | ✅ Aprovado |
| **Total Geral** | **4 arquivos de testes** | **18** | **✅ 100% Aprovado** |

### 3.4. Testes End-to-End (E2E) com Cypress (`cypress/`)
Para garantir compatibilidade de nível industrial com ferramentas consagradas da web, configuramos o **Cypress (v13.17.0)**. O arquivo `cypress/e2e/petshop_web.cy.js` realiza testes de integração reais contra os endpoints da API REST, ViaCEP e Dog API:

```text
  Running:  petshop_web.cy.js                                                               (1 of 1)

  Testes E2E com Cypress - Pet Shop Patas & Pelos (Digital Horizon)
    √ CT01: Deve consultar a API REST mock de produtos com sucesso e retornar catálogo (145ms)
    √ CT02: Deve consultar a API REST mock de serviços do Pet Shop (57ms)
    √ CT03: Deve consultar as promoções e cupons da loja (47ms)
    √ CT04: Deve validar a integração com a Dog API pública externa (dog.ceo) (489ms)
    √ CT05: Deve validar a integração com a API pública ViaCEP para cálculo de entrega (798ms)

  5 passing (2s)
  √  All specs passed!
```

---

## 🚀 4. Guia Passo a Passo: Como Rodar o Projeto e os Testes

Siga as etapas abaixo para instalar as dependências, rodar a suíte de testes automatizados e executar a aplicação no navegador Web (Google Chrome) ou no emulador Android.

### 📋 Pré-requisitos
Certifique-se de possuir em seu computador:
1. **Flutter SDK** instalado (versão 3.22 ou superior).  
   *Para verificar:* abra o terminal e digite `flutter --version`.
2. **Node.js e npm/npx** instalados.  
   *Para verificar:* digite `node -v` e `npx -v`.
3. Navegador **Google Chrome** instalado (para execução Web).

---

### 🔹 Passo 1: Abrir o Terminal na Pasta do Projeto
Abra o terminal (PowerShell, CMD ou Bash) e navegue até a pasta raiz do código Flutter:
```bash
cd "vini_somativa dia 11 - Copia\vini_somativa dia 11 - Copia"
```
*(Certifique-se de que o comando `dir` ou `ls` mostre os arquivos `pubspec.yaml`, `db.json` e a pasta `lib/`)*

---

### 🔹 Passo 2: Baixar os Pacotes e Dependências
Execute o comando abaixo para baixar todas as bibliotecas necessárias (`provider`, `http`, `hive`, `get_it`, etc.):
```bash
flutter pub get
```
> **Saída esperada:** `Resolving dependencies... Got dependencies!`.

---

### 🔹 Passo 3: Executar os Testes Automatizados Unitários (Flutter Test)
Execute a suíte de testes unitários:
```bash
flutter test
```
* **O que este comando faz:** compila e executa todos os 13 testes unitários e de integração mockada em modo headless.
* **Saída esperada ao final:**
  ```text
  00:00 +13: All tests passed!
  ```

---

### 🔹 Passo 4: Executar os Testes Automatizados E2E com Cypress (Ferramenta Web)
Com o servidor de mock rodando (ou com o `npx json-server` ativo), você pode executar o Cypress de duas formas:

#### Opção A: Executar pelo Terminal (Modo Headless / Rápido)
```bash
npx cypress run
```
*(ou `npm run cypress:run`)*
* **O que faz:** roda os 5 testes E2E diretamente no terminal com Electron/Chrome headless e exibe a tabela de resultados (`All specs passed!`).

#### Opção B: Abrir a Interface Gráfica Interativa do Cypress
```bash
npx cypress open
```
*(ou `npm run cypress:open`)*
* **O que faz:** abre a janela oficial do Cypress para você visualizar os testes rodando em tempo real na tela do navegador, inspecionar cada requisição HTTP e acompanhar as asserções visuais.

---

### 🔹 Passo 5: Iniciar o Servidor Mock de Banco de Dados (`json-server`)
Abra uma **nova janela de terminal** (mantenha a pasta do projeto aberta) e execute:
```bash
npx json-server --watch db.json --port 3000
```
* **O que este comando faz:** inicializa a API RESTful local com os dados de produtos, serviços e promoções.
* **Endpoints disponíveis:**
  * `http://localhost:3000/products`
  * `http://localhost:3000/services`
  * `http://localhost:3000/promotions`
> ⚠️ **Atenção:** Deixe este terminal aberto enquanto estiver usando o aplicativo ou executando os testes do Cypress.

---

### 🔹 Passo 6: Executar o Aplicativo Flutter

#### Opção A: Executar no Google Chrome (Aplicação Web)
Em um terminal aberto na pasta do projeto, execute:
```bash
flutter run -d chrome
```
* O Flutter irá compilar a aplicação para Web e abrir automaticamente o Google Chrome conectado em `http://localhost:port`.
* A constante de conexão detectará automaticamente o ambiente web (`kIsWeb`) e se conectará à API em `http://localhost:3000`.

#### Opção B: Executar no Emulador Android
Com o emulador Android aberto (ou celular conectado via USB com depuração ativada), execute:
```bash
flutter run
```
* O aplicativo detectará o emulador Android e utilizará o endereço de ponte `http://10.0.2.2:3000`.

---

## 📂 5. Estrutura de Pastas do Projeto
```text
lib/
├── core/
│   └── constants.dart         # Detecção dinâmica de plataforma (Web vs Android)
├── data/
│   ├── models/                # DTOs com serialização JSON (ProductModel, PetServiceModel, etc.)
│   ├── providers/             # ApiProvider (ProductRepository) e LocalProvider (Hive)
│   └── services/              # ApiService, ViaCepService, DogApiService
├── domain/
│   ├── entities/              # Entidades Product e PetProduct (POO)
│   ├── repositories/          # Interface ProductRepository
│   └── usecases/              # Casos de uso (CRUD de produtos e carrinho)
├── presentation/
│   ├── screens/               # HomeScreen, ProductDetail, ProductFormScreen, CartScreen, LoginScreen
│   └── widgets/               # ProductCard responsivo e componentes
├── injection.dart             # Injeção de dependências com GetIt
└── main.dart                  # Inicialização do app, Hive e Providers
test/
├── dog_api_service_test.dart  # Testes unitários do serviço externo Dog API e dicas
├── product_model_test.dart    # Testes unitários de modelos e POO
└── usecases_test.dart         # Testes unitários dos casos de uso (Clean Architecture)
cypress/
└── e2e/
    └── petshop_web.cy.js      # Testes E2E automatizados com Cypress para Web
cypress.config.js              # Configuração oficial do Cypress
package.json                   # Dependências e scripts de execução do Cypress e mock
db.json                        # Banco de dados externo mock (produtos, serviços, promoções)
```
