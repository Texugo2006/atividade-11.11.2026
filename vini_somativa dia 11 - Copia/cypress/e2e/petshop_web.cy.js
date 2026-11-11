// cypress/e2e/petshop_web.cy.js
describe('Testes E2E com Cypress - Pet Shop Patas & Pelos (Digital Horizon)', () => {

  it('CT01: Deve consultar a API REST mock de produtos com sucesso e retornar catálogo', () => {
    cy.request('GET', 'http://localhost:3000/products').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.be.an('array');
      expect(response.body.length).to.be.greaterThan(0);

      const firstProduct = response.body[0];
      expect(firstProduct).to.have.property('id');
      expect(firstProduct).to.have.property('name');
      expect(firstProduct).to.have.property('price');
      expect(firstProduct).to.have.property('imageUrl');
      expect(firstProduct).to.have.property('breed');
      expect(firstProduct).to.have.property('brand');
    });
  });

  it('CT02: Deve consultar a API REST mock de serviços do Pet Shop', () => {
    cy.request('GET', 'http://localhost:3000/services').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.be.an('array');
      expect(response.body.length).to.be.at.least(4);

      const names = response.body.map(s => s.name);
      expect(names).to.include('Banho & Tosa Higiênica Completo');
      expect(names).to.include('Consulta Veterinária Preventiva');
    });
  });

  it('CT03: Deve consultar as promoções e cupons da loja', () => {
    cy.request('GET', 'http://localhost:3000/promotions').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.be.an('array');
      expect(response.body[0]).to.have.property('coupon');
    });
  });

  it('CT04: Deve validar a integração com a Dog API pública externa (dog.ceo)', () => {
    cy.request('GET', 'https://dog.ceo/api/breeds/image/random').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body.status).to.eq('success');
      expect(response.body.message).to.match(/^https:\/\/images\.dog\.ceo\/breeds\/.+/);
    });
  });

  it('CT05: Deve validar a integração com a API pública ViaCEP para cálculo de entrega', () => {
    cy.request('GET', 'https://viacep.com.br/ws/01001000/json/').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('cep');
      expect(response.body).to.have.property('logradouro');
      expect(response.body.localidade).to.eq('São Paulo');
    });
  });

});
