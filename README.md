# Meu Projeto Ticketz Personalizado

Bem-vindo ao meu fork personalizado do Ticketz!

Este projeto é uma versão modificada e mantida por **Gil Lima - Ideia no Bolso**. O objetivo é fornecer uma solução de comunicação via WhatsApp com funcionalidades de CRM e helpdesk, totalmente adaptada às minhas necessidades e com novas funcionalidades desenvolvidas sob medida.

---

## Instalação Rápida (em um Servidor Público com Docker)

Para rodar este sistema na sua VPS ou servidor público, siga os passos abaixo. Certifique-se de ter Docker e Docker Compose instalados.

**Pré-requisitos:**
* Um servidor limpo (Ubuntu 20+ recomendado).
* Portas 80 e 443 disponíveis e não filtradas por firewall.
* Dois hostnames com DNS configurado apontando para o seu servidor (um para o backend/API e outro para o frontend/interface web). Ex: `api.ideianobolso.com.br` e `app.ideianobolso.com.br`.
* Um endereço de e-mail para registro dos certificados SSL (Let's Encrypt).

**Passos para Instalação:**

1.  **Faça login na sua VPS via SSH.**

2.  **Clone este repositório para o seu servidor:**
    ```bash
    cd ~
    git clone [https://github.com/gilderlanlima/projetoz.git](https://github.com/gilderlanlima/projetoz.git)
    cd projetoz
    ```

3.  **Configure suas variáveis de ambiente:**
    Edite os arquivos `.env-backend-acme` e `.env-frontend-acme` na raiz do projeto.
    ```bash
    # Exemplo para o backend:
    # Abra com um editor de texto (nano ou vim)
    nano .env-backend-acme
    # Altere as URLs e o e-mail conforme seus domínios
    # EX: API_URL=[https://api.ideianobolso.com.br](https://api.ideianobolso.com.br)
    # EX: WSS_URL=wss://api.ideianobolso.com.br/whatsapp
    # EX: JWT_SECRET=algum_segredo_complexo_e_unico_aqui (gerar um novo e forte!)
    # EX: ACME_EMAIL=contato@ideianobolso.com.br
    
    # Faça o mesmo para o frontend:
    nano .env-frontend-acme
    # EX: REACT_APP_BACKEND_URL=[https://api.ideianobolso.com.br](https://api.ideianobolso.com.br)
    # EX: REACT_APP_FRONTEND_URL=[https://app.ideianobolso.com.br](https://app.ideianobolso.com.br)
    # EX: REACT_APP_CONTACT_EMAIL=contato@ideianobolso.com.br
    ```
    **Importante:** Gere um novo e forte `JWT_SECRET` para a segurança da sua aplicação!

4.  **Inicie o serviço Docker Compose:**
    ```bash
    sudo docker compose -f docker-compose-acme.yaml up -d
    ```
    Aguarde alguns minutos. O Docker irá construir as imagens e iniciar os serviços.

5.  **Acesse o Ticketz:**
    Após a conclusão, o sistema estará acessível pelo endereço do seu frontend (`https://app.ideianobolso.com.br`).
    * **Login Padrão:** O e-mail que você configurou no `.env-backend-acme`.
    * **Senha Padrão:** `123456` (Altere imediatamente após o primeiro login!).

---

## Customizações e Desenvolvimento

Este projeto está sob sua total liberdade para customização. Explore o código em `backend/` e `frontend/` para implementar novas funcionalidades, ajustar o fluxo do chatbot e integrar com outros sistemas.

Sinta-se à vontade para abrir issues ou pull requests no seu próprio repositório para gerenciar suas modificações.

---

**Aviso Importante:** Este projeto é uma modificação do Ticketz (que por sua vez é derivado do Whaticket). Não é afiliado à Meta, WhatsApp ou qualquer outra empresa. A utilização do código modificado é de sua responsabilidade exclusiva.