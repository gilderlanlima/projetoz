#!/bin/bash

# Cores para mensagens
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando a instalação do ProjetoZ...${NC}"

# --- Validação de argumentos ---
if [ "$#" -ne 3 ]; then
    echo -e "${RED}Uso: sudo bash -s <frontend_url> <backend_url> <admin_email>${NC}"
    echo -e "${RED}Exemplo: sudo bash -s crm.meuprojeto.com crm-bk.meuprojeto.com contato@meuprojeto.com${NC}"
    exit 1
fi

FRONTEND_URL="$1"
BACKEND_URL="$2"
ACME_EMAIL="$3"

echo -e "${YELLOW}Configurações recebidas:${NC}"
echo -e "${YELLOW}Frontend URL: ${FRONTEND_URL}${NC}"
echo -e "${YELLOW}Backend URL: ${BACKEND_URL}${NC}"
echo -e "${YELLOW}Email ACME: ${ACME_EMAIL}${NC}"
sleep 2

# --- Limpeza de instalações anteriores ---
echo -e "${YELLOW}Verificando e removendo instalações Docker anteriores do ProjetoZ...${NC}"

# Navega para /root para garantir que o docker compose down seja executado no contexto correto
cd /root/ 2>/dev/null || true

# Tenta derrubar e remover volumes do docker-compose-acme.yaml se existir
if [ -f "/root/projetoz/docker-compose-acme.yaml" ]; then
    echo -e "${YELLOW}Encontrado docker-compose-acme.yaml. Derrubando contêineres e removendo volumes...${NC}"
    sudo docker compose -f /root/projetoz/docker-compose-acme.yaml down -v --remove-orphans 2>/dev/null || true
else
    echo -e "${YELLOW}docker-compose-acme.yaml não encontrado. Pulando docker compose down.${NC}"
fi

# Remove todos os contêineres e volumes restantes (cuidado, isso afeta tudo no Docker)
echo -e "${YELLOW}Removendo todos os contêineres e volumes Docker restantes. Isso pode afetar outros projetos Docker nesta VPS!${NC}"
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null || true
sudo docker volume rm $(sudo docker volume ls -q) 2>/dev/null || true

# Remove o diretório do projeto
if [ -d "/root/projetoz" ]; then
    echo -e "${YELLOW}Removendo diretório /root/projetoz...${NC}"
    sudo rm -rf /root/projetoz
else
    echo -e "${YELLOW}Diretório /root/projetoz não encontrado. Pulando remoção.${NC}"
fi

echo -e "${GREEN}Limpeza concluída.${NC}"
sleep 2

# --- Clonar o repositório ---
echo -e "${YELLOW}Clonando o repositório do ProjetoZ para /root/projetoz...${NC}"
if git clone https://github.com/gilderlanlima/projetoz.git /root/projetoz; then
    echo -e "${GREEN}Repositório clonado com sucesso!${NC}"
else
    echo -e "${RED}Erro: Falha ao clonar o repositório. Verifique sua conexão ou o repositório.${NC}"
    exit 1
fi

cd /root/projetoz || { echo -e "${RED}Erro: Não foi possível navegar para /root/projetoz. Saindo.${NC}"; exit 1; }

# --- Verificação e instalação do Docker e Docker Compose ---
echo -e "${YELLOW}Verificando a instalação do Docker e Docker Compose...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker não encontrado. Instale o Docker primeiro.${NC}"
    echo -e "${YELLOW}Sugestão: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh${NC}"
    exit 1
fi

# Verifica se o Docker Compose está instalado como plugin ou comando separado
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose não encontrado. Instale o Docker Compose (plugin ou standalone).${NC}"
    exit 1
fi
echo -e "${GREEN}Docker e Docker Compose detectados.${NC}"

# --- Configuração dos arquivos .env ---
echo -e "${YELLOW}Configurando arquivos de ambiente...${NC}"

# Backend ACME
cp .env-backend-acme.example .env-backend-acme
sed -i "s|API_URL=.*|API_URL=https://${BACKEND_URL}|" .env-backend-acme
sed -i "s|WSS_URL=.*|WSS_URL=wss://${BACKEND_URL}/whatsapp|" .env-backend-acme
sed -i "s|ACME_EMAIL=.*|ACME_EMAIL=${ACME_EMAIL}|" .env-backend-acme

# Frontend ACME
cp .env-frontend-acme.example .env-frontend-acme
sed -i "s|REACT_APP_BACKEND_URL=.*|REACT_APP_BACKEND_URL=https://${BACKEND_URL}|" .env-frontend-acme
sed -i "s|REACT_APP_FRONTEND_URL=.*|REACT_APP_FRONTEND_URL=https://${FRONTEND_URL}|" .env-frontend-acme
sed -i "s|REACT_APP_CONTACT_EMAIL=.*|REACT_APP_CONTACT_EMAIL=${ACME_EMAIL}|" .env-frontend-acme

echo -e "${GREEN}Arquivos .env configurados.${NC}"

# --- Preparar docker-compose-acme.yaml para as variáveis de ambiente corretas ---
echo -e "${YELLOW}Configurando docker-compose-acme.yaml para os domínios informados...${NC}"

# Cria um backup do docker-compose-acme.yaml original antes de modificar
cp docker-compose-acme.yaml docker-compose-acme.yaml.bak

# Insere as variáveis de ambiente VIRTUAL_HOST e LETSENCRYPT_HOST diretamente no serviço nginx-proxy
# e DEFAULT_EMAIL para acme-companion no docker-compose-acme.yaml
# Isso é mais robusto do que depender de .env externo para esses valores em tempo de execução do compose.

# Usar um método mais seguro e menos propenso a erros de sed para adicionar blocos
# Temporary file for modified compose
TEMP_COMPOSE_FILE=$(mktemp)

# Read original compose file line by line
while IFS= read -r line; do
    echo "$line" >> "$TEMP_COMPOSE_FILE"
    if [[ "$line" =~ "container_name: ticketz-nginx-proxy" ]]; then
        echo "      environment:" >> "$TEMP_COMPOSE_FILE"
        echo "        - VIRTUAL_HOST=${FRONTEND_URL},${BACKEND_URL}" >> "$TEMP_COMPOSE_FILE"
        echo "        - LETSENCRYPT_HOST=${FRONTEND_URL},${BACKEND_URL}" >> "$TEMP_COMPOSE_FILE"
    elif [[ "$line" =~ "container_name: ticketz-acme-companion" ]]; then
        echo "      environment:" >> "$TEMP_COMPOSE_FILE"
        echo "        - DEFAULT_EMAIL=${ACME_EMAIL}" >> "$TEMP_COMPOSE_FILE"
    fi
done < docker-compose-acme.yaml

# Replace original with modified
mv "$TEMP_COMPOSE_FILE" docker-compose-acme.yaml

echo -e "${GREEN}docker-compose-acme.yaml configurado.${NC}"

# --- Subir os contêineres Docker ---
echo -e "${YELLOW}Iniciando os serviços Docker. Isso pode levar alguns minutos para a emissão do certificado SSL...${NC}"
if sudo docker compose -f docker-compose-acme.yaml up -d --build; then
    echo -e "${GREEN}Serviços Docker iniciados com sucesso!${NC}"
else
    echo -e "${RED}Erro: Falha ao iniciar os serviços Docker. Verifique os logs para mais detalhes.${NC}"
    exit 1
fi

echo -e "${YELLOW}Aguarde alguns minutos para que o Let's Encrypt emita e instale os certificados SSL.${NC}"
echo -e "${YELLOW}Você pode verificar o status com: sudo docker logs --details --timestamps ticketz-acme-companion${NC}"
echo -e "${YELLOW}Ou verificar os contêineres com: sudo docker ps -a${NC}"

echo -e "${GREEN}Instalação do ProjetoZ concluída!${NC}"
echo -e "${GREEN}Acesse seu Frontend em: https://${FRONTEND_URL}${NC}"
echo -e "${GREEN}Acesse seu Backend em: https://${BACKEND_URL}${NC}"