#!/bin/bash
set -e

# Print Elixir and Erlang versions
echo "Elixir version: $(elixir --version)"
echo "Erlang version: $(erl -version)"

# Ensure hex and rebar are up to date
mix local.hex --force
mix local.rebar --force

# Wait for database
echo "Waiting for MySQL database..."
while ! nc -z db 3306; do
  sleep 1
done
echo "MySQL database is ready"

# Get and compile dependencies
echo "Fetching dependencies..."
mix deps.get
mix deps.compile

# Run database migrations and seeds
mix ecto.create || true
mix ecto.migrate
mix run priv/repo/seeds.exs || true

# Print unchecked dependencies (for debugging)
echo "Checking dependencies..."
mix deps.get

# Start the Phoenix server
echo "Starting Phoenix server..."
exec mix phx.server