#!/bin/bash
set -e

# Esperar pelo MySQL
echo "Waiting for MySQL..."
while ! nc -z $DB_HOST 3306; do
  sleep 1
done
echo "MySQL started"

# Configuração específica para ambiente de teste
if [ "$MIX_ENV" = "test" ]; then
  echo "Setting up test environment..."
  while ! nc -z $TEST_DB_HOST 3306; do
    sleep 1
  done
  echo "Test database started"
  
  # Configurar banco de dados de teste
  mix ecto.drop || true
  mix ecto.create
  mix ecto.migrate
fi

# Executar o comando fornecido
exec "$@"