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
