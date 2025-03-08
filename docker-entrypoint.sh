#!/bin/bash
set -e

# Função para verificar conexão com o banco de dados
function wait_for_db() {
  local host=$1
  local port=$2
  echo "Aguardando banco de dados $host:$port..."
  
  while ! nc -z $host $port; do
    sleep 1
  done
  
  echo "Banco de dados disponível"
}

# Aguardar banco de dados
if [ "$MIX_ENV" = "test" ]; then
  wait_for_db $TEST_DB_HOST 3306
else
  wait_for_db $DB_HOST 3306
  
  # Esperar um pouco mais para garantir que o MySQL esteja realmente pronto para aceitar conexões
  sleep 5
  
  echo "Preparando o banco de dados..."
  

  mix ecto.drop || true
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
fi

exec "$@"