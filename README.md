# Caju
Configuração ambiente MySQL usando Ubuntu:

sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

mysql -u root -p
rodar todos comandos do arquivo comandos.sql
rodar todos os comandos do arquivo inserts.sql

Instalar Elixir e Erlang usando Ubuntu:

sudo apt update
sudo apt install erlang elixir
elixir --version
mix archive.install hex phx_new 1.7.0

Projeto clonado acessar 

cd caju
mix deps.get
mix phx.server -- rodar a api
