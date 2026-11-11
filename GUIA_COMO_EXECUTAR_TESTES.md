# 📖 Guia Prático: Como Executar Qualquer Teste no Projeto
**Pet Shop Patas & Pelos – Digital Horizon**

Este documento é um manual completo e didático para você aprender a executar **qualquer teste** no projeto — sejam testes unitários no Flutter, testes automatizados Web com Cypress ou testes manuais de ponta a ponta na interface.

---

## 📑 Índice Rápido
1. [Pré-requisitos e Preparação do Ambiente](#1-pré-requisitos-e-preparação-do-ambiente)
2. [Como Rodar Testes Automatizados no Flutter (`flutter test`)](#2-como-rodar-testes-automatizados-no-flutter-flutter-test)
   - [2.1. Rodar todos os testes de uma vez](#21-rodar-todos-os-testes-de-uma-vez)
   - [2.2. Rodar apenas um arquivo de teste específico](#22-rodar-apenas-um-arquivo-de-teste-específico)
   - [2.3. Rodar apenas um teste específico pelo nome](#23-rodar-apenas-um-teste-específico-pelo-nome)
   - [2.4. Rodar testes com detalhes linha a linha (Modo Verbose)](#24-rodar-testes-com-detalhes-linha-a-linha-modo-verbose)
3. [Como Rodar Testes E2E com Cypress (Aplicações Web)](#3-como-rodar-testes-e2e-com-cypress-aplicações-web)
   - [3.1. Modo Terminal / Rápido (`cypress run`)](#31-modo-terminal--rápido-cypress-run)
   - [3.2. Modo Visual Interativo na Tela (`cypress open`)](#32-modo-visual-interativo-na-tela-cypress-open)
   - [3.3. Rodar apenas um arquivo de teste específico no Cypress](#33-rodar-apenas-um-arquivo-de-teste-específico-no-cypress)
4. [Como Criar um Novo Teste no Projeto](#4-como-criar-um-novo-teste-no-projeto)
   - [4.1. Criando um novo teste no Flutter](#41-criando-um-novo-teste-no-flutter)
   - [4.2. Criando um novo teste no Cypress](#42-criando-um-novo-teste-no-cypress)
5. [Como Executar Testes Manuais Funcionais na Interface](#5-como-executar-testes-manuais-funcionais-na-interface)
6. [Tabela Resumo de Comandos Rápidos](#6-tabela-resumo-de-comandos-rápidos)

---

## 1. Pré-requisitos e Preparação do Ambiente

Antes de iniciar qualquer execução, certifique-se de que o seu terminal está posicionado na pasta principal do código do projeto.

### 📍 Abrir o Terminal na pasta correta:
```bash
cd "c:\Users\kaique.daniel_superl\Downloads\vini_somativa dia 11 - Copia\vini_somativa dia 11 - Copia"
```
*(Dica: execute `dir` ou `ls` e verifique se aparecem os arquivos `pubspec.yaml`, `package.json` e `db.json`)*.

### 🌐 Iniciar o Banco de Dados Mock (`json-server`):
Para testes que dependem do catálogo de produtos e serviços (como o Cypress ou o app rodando), abra uma **segunda janela de terminal** e execute:
```bash
npx json-server --watch db.json --port 3000
```
> 💡 *Deixe essa janela aberta minimizada enquanto realiza os testes.*

---

## 2. Como Rodar Testes Automatizados no Flutter (`flutter test`)

Os testes do Flutter validam a lógica interna, regras de negócio (Clean Architecture), modelos de dados (POO) e integração das APIs sem precisar abrir o aplicativo.

### 2.1. Rodar todos os testes de uma vez
Para rodar toda a suíte de testes unitários do projeto:
```bash
flutter test
```
* **O que acontece:** O Flutter compila todos os testes da pasta `test/` e roda em segundo plano.
* **Resultado esperado:**
  ```text
  00:00 +13: All tests passed!
  ```

---

### 2.2. Rodar apenas um arquivo de teste específico
Se você quiser testar apenas uma parte do sistema, pode passar o caminho direto do arquivo:

* **Para testar apenas os Modelos e regras de POO:**
  ```bash
  flutter test test/product_model_test.dart
  ```

* **Para testar apenas os Casos de Uso (CRUD de Produtos):**
  ```bash
  flutter test test/usecases_test.dart
  ```

* **Para testar apenas o serviço da Dog API e as dicas da raça:**
  ```bash
  flutter test test/dog_api_service_test.dart
  ```

---

### 2.3. Rodar apenas um teste específico pelo nome
Se quiser executar apenas um único teste dentro de um arquivo (por exemplo, apenas o teste de tradução de raças):
```bash
flutter test --plain-name "Deve formatar raças conhecidas"
```
Ou para testar apenas o caso de uso de criação:
```bash
flutter test --plain-name "CreateProduct"
```

---

### 2.4. Rodar testes com detalhes linha a linha (Modo Verbose / Expandido)
Para ver o nome de cada teste sendo executado em tempo real, use a flag `-r expanded`:
```bash
flutter test -r expanded
```
* **Saída esperada:** Lista cada um dos 13 testes com um `+` verde ao lado, confirmando que passou.

---

## 3. Como Rodar Testes E2E com Cypress (Aplicações Web)

O **Cypress** é a ferramenta padrão de mercado para testar aplicações Web, validando endpoints REST, JSONs, integrações externas (Dog API, ViaCEP) e fluxos completos de tela.

> ⚠️ **Atenção:** Antes de rodar o Cypress, garanta que o `json-server` está rodando na porta 3000 (`npx json-server --watch db.json --port 3000`).

---

### 3.1. Modo Terminal / Rápido (`cypress run`)
Ideal para validações rápidas no próprio prompt ou integração contínua (CI):
```bash
npx cypress run
```
*(ou se preferir: `npm run cypress:run`)*

* **O que acontece:** O Cypress inicia o navegador headless (Electron) em segundo plano, executa os testes em cerca de 2 segundos e exibe a tabela de aprovação:
  ```text
  Running: petshop_web.cy.js
    √ CT01: Deve consultar a API REST mock de produtos (145ms)
    √ CT02: Deve consultar a API REST mock de serviços do Pet Shop (57ms)
    √ CT03: Deve consultar as promoções e cupons da loja (47ms)
    √ CT04: Deve validar a integração com a Dog API pública externa (489ms)
    √ CT05: Deve validar a integração com a API pública ViaCEP (798ms)

  5 passing (2s)
  √ All specs passed!
  ```

---

### 3.2. Modo Visual Interativo na Tela (`cypress open`)
Ideal para você demonstrar o funcionamento, inspecionar erros e ver os testes rodando com interface gráfica:
```bash
npx cypress open
```
*(ou `npm run cypress:open`)*

#### Passo a passo na interface do Cypress:
1. Uma janela estilizada do Cypress vai abrir na tela.
2. Clique no card **"E2E Testing"** (que estará com selo verde *Configured*).
3. Selecione o navegador desejado (ex: **Chrome** ou **Electron**).
4. Clique no botão verde **"Start E2E Testing in Chrome"**.
5. O navegador abrirá listando os arquivos de teste. Clique em:
   👉 **`petshop_web.cy.js`**
6. O Cypress executará os testes diante dos seus olhos, exibindo cada requisição HTTP, tempo de resposta e o resultado verde de aprovação.

---

### 3.3. Rodar apenas um arquivo de teste específico no Cypress
Quando tiver múltiplos arquivos de teste na pasta `cypress/e2e/`, execute:
```bash
npx cypress run --spec "cypress/e2e/petshop_web.cy.js"
```

---

## 4. Como Criar um Novo Teste no Projeto

### 4.1. Criando um novo teste no Flutter
1. Crie ou abra um arquivo na pasta `test/` (ex: `test/meu_novo_teste.dart`).
2. Adicione a estrutura padrão:
   ```dart
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     test('Deve calcular o desconto de um produto com sucesso', () {
       final precoOriginal = 100.0;
       final desconto = 15.0; // 15%
       final precoFinal = precoOriginal * (1 - desconto / 100);

       expect(precoFinal, equals(85.0));
     });
   }
   ```
3. Execute no terminal:
   ```bash
   flutter test test/meu_novo_teste.dart
   ```

---

### 4.2. Criando um novo teste no Cypress
1. Crie ou abra um arquivo na pasta `cypress/e2e/` (ex: `cypress/e2e/novo_teste.cy.js`).
2. Adicione a estrutura com `cy.request`:
   ```javascript
   describe('Meu Novo Teste de API', () => {
     it('Deve verificar se a API está ativa', () => {
       cy.request('http://localhost:3000/products').then((resposta) => {
         expect(resposta.status).to.eq(200);
         expect(resposta.body).to.have.length.greaterThan(0);
       });
     });
   });
   ```
3. Execute no terminal:
   ```bash
   npx cypress run --spec "cypress/e2e/novo_teste.cy.js"
   ```

---

## 5. Como Executar Testes Manuais Funcionais na Interface

Para testar visualmente no navegador como se fosse o cliente final:

### Passo 1: Subir o App no Google Chrome
```bash
flutter run -d chrome
```

### Roteiro de Testes Manuais:

| Cenário de Teste | O que fazer no App | Resultado Esperado |
| :--- | :--- | :--- |
| **1. Busca de Produtos** | Digite "Ração" no campo de pesquisa da Home. | Apenas as rações devem aparecer na grade. |
| **2. Filtro de Categoria** | Troque o dropdown de "Todas" para "Gatos". | Apenas produtos da categoria Gatos permanecem visíveis. |
| **3. Cadastro de Produto** | Clique no botão `+` (canto inferior direito), preencha nome, preço e clique em Salvar. | O novo produto aparece no catálogo e é salvo no `db.json`. |
| **4. Edição de Produto** | Clique no ícone de lápis de um produto, altere o valor e salve. | O valor atualizado reflete imediatamente no card. |
| **5. Exclusão de Produto** | Clique no ícone de lixeira e confirme a exclusão. | O produto é removido da tela e do `db.json`. |
| **6. Carrinho e Frete** | Clique no botão de carrinho em 2 produtos, acesse a aba Carrinho e digite um CEP válido (ex: `01001-000`). | O app busca o endereço via ViaCEP e calcula o subtotal + frete. |
| **7. Sorteio de Cão e Dicas** | Acesse a aba **"Curiosidades Pet"** e clique no botão *"Sortear Outro Cachorro"*. | A foto muda, o selo da raça é exibido em português e 3 dicas especializadas da raça são geradas. |
| **8. Agendamento Local** | Acesse a aba **"Serviços"**, clique em *"Agendar"* em Banho e Tosa, informe o nome do pet e confirme. | O agendamento é salvo com segurança no banco local Hive (sem expor na web). |

---

## 6. Tabela Resumo de Comandos Rápidos

| Objetivo | Comando a executar no terminal |
| :--- | :--- |
| **Rodar todos os testes unitários do Flutter** | `flutter test` |
| **Rodar testes do Flutter com relatório expandido** | `flutter test -r expanded` |
| **Rodar um arquivo específico do Flutter** | `flutter test test/dog_api_service_test.dart` |
| **Rodar todos os testes Web com Cypress (Terminal)** | `npx cypress run` |
| **Abrir interface gráfica do Cypress na tela** | `npx cypress open` |
| **Rodar um teste específico do Cypress** | `npx cypress run --spec "cypress/e2e/petshop_web.cy.js"` |
| **Iniciar o servidor de banco de dados mock** | `npx json-server --watch db.json --port 3000` |
| **Rodar o aplicativo no navegador Chrome** | `flutter run -d chrome` |
| **Rodar o aplicativo no Emulador Android** | `flutter run` |
