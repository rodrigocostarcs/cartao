# Caju - Guia de Configuração e Execução

## Configuração do Ambiente MySQL no Ubuntu

### Atualize os pacotes:
```bash
sudo apt update
```

### Instale o MySQL Server:
```bash
sudo apt install mysql-server
```

### Inicie e habilite o MySQL:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Acesse o MySQL:
```bash
mysql -u root -p
```

### Execute os comandos dos arquivos `comandos.sql` e `inserts.sql` para configurar o banco de dados.

---

## Instalação do Elixir e Erlang no Ubuntu

### Atualize os pacotes:
```bash
sudo apt update
```

### Instale Erlang e Elixir:
```bash
sudo apt install erlang elixir
```

### Verifique a versão:
```bash
elixir --version
```

### Instale as ferramentas do Phoenix Framework:
```bash
mix archive.install hex phx_new 1.7.0
```

---

## Configuração do Projeto

### Clone o repositório e acesse a pasta do projeto:
```bash
cd caju
```

### Instale as dependências:
```bash
mix deps.get
```

### Configure o arquivo `config/dev.exs` com as credenciais do banco de dados:
```elixir
username: "root",
password: "senha",
hostname: "localhost",
database: "caju_dev",
stacktrace: true,
show_sensitive_data_on_connection_error: true,
pool_size: 10
```

---

## Execução do Projeto

### Execute o servidor Phoenix:
```bash
mix phx.server
```

A API estará disponível em: [http://127.0.0.1:4000](http://127.0.0.1:4000)

---

## Testando a API com Postman

- Utilize o Postman para testar as requisições REST.
- O arquivo `caju.postman_collection.json`, localizado na raiz do projeto, contém todas as requisições configuradas.

### Fluxo de Teste:
1. Realizar login com os dados do estabelecimento (já inseridos no banco de dados pelos scripts).
2. A autenticação gera um token JWT.
3. O token JWT deve ser utilizado nas demais requisições.
4. O tempo de expiração do token está definido como 1 minuto para fins de teste.
5. Cada requisição no arquivo Postman contém uma situação de teste específica, conforme o proposto.

### Dica:
Sempre verifique se o banco de dados está ativo antes de iniciar o servidor Phoenix.

