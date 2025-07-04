#!/bin/bash

# Este script instala o ProjetoZ em um servidor Ubuntu 22.04+ com Docker.
# Uso: curl -sSL SEU_DOMINIO_PARA_SCRIPT/install.sh | sudo bash -s frontend.seu_dominio.com backend.seu_dominio.com seu_email@dominio.com

FRONTEND_URL=$1
BACKEND_URL=$2
ADMIN_EMAIL=$3

if [ -z "$FRONTEND_URL" ] || [ -z "$BACKEND_URL" ] || [ -z "$ADMIN_EMAIL" ]; then
    echo "Uso: sudo bash -s <frontend_url> <backend_url> <admin_email>"
    echo "Exemplo: sudo bash -s crm.meuprojeto.com crm-bk.meuprojeto.com contato@meuprojeto.com"
    exit 1
fi

echo "Iniciando a instalação do ProjetoZ..."
echo "Frontend URL: ${FRONTEND_URL}"
echo "Backend URL: ${BACKEND_URL}"
echo "Email Admin: ${ADMIN_EMAIL}"
echo "------------------------------------"

# Instalar dependências essenciais (Git, Docker, Docker Compose)
apt update -y
apt upgrade -y
apt install git -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
apt install docker-compose -y
systemctl enable docker
systemctl start docker

# Clonar o repositório do ProjetoZ (usando URL pública, se o repositório for público)
cd /root
rm -rf projetoz # Garante limpeza
git clone https://github.com/gilderlanlima/projetoz.git
cd projetoz

# Gerar JWT_SECRET
JWT_SECRET=$(openssl rand -hex 32)

# Configurar arquivos .env
# Backend
cp .env-backend-acme.example .env-backend-acme
sed -i "s|API_URL=.*|API_URL=https://${BACKEND_URL}|g" .env-backend-acme
sed -i "s|WSS_URL=.*|WSS_URL=wss://${BACKEND_URL}/whatsapp|g" .env-backend-acme
sed -i "s|ACME_EMAIL=.*|ACME_EMAIL=${ADMIN_EMAIL}|g" .env-backend-acme
sed -i "s|JWT_SECRET=.*|JWT_SECRET=${JWT_SECRET}|g" .env-backend-acme

# Frontend
cp .env-frontend-acme.example .env-frontend-acme
sed -i "s|REACT_APP_BACKEND_URL=.*|REACT_APP_BACKEND_URL=https://${BACKEND_URL}|g" .env-frontend-acme
sed -i "s|REACT_APP_FRONTEND_URL=.*|REACT_APP_FRONTEND_URL=https://${FRONTEND_URL}|g" .env-frontend-acme
sed -i "s|REACT_APP_CONTACT_EMAIL=.*|REACT_APP_CONTACT_EMAIL=${ADMIN_EMAIL}|g" .env-frontend-acme

# Iniciar Docker Compose
sudo docker compose -f docker-compose-acme.yaml up -d

echo "------------------------------------"
echo "Instalação do ProjetoZ concluída!"
echo "Acesse em: https://${FRONTEND_URL}"
echo "Login Padrão: ${ADMIN_EMAIL}"
echo "Senha Padrão: 123456 (Altere imediatamente!)"
echo "------------------------------------"