defmodule Caju.Repo.Migrations.CreateCajuTables do
  use Ecto.Migration

  def change do
    # Tabela contas
    execute "CREATE TABLE contas (
      id INT AUTO_INCREMENT PRIMARY KEY,
      numero_conta VARCHAR(255) NOT NULL UNIQUE,
      nome_titular VARCHAR(255) NOT NULL,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )"

    # Tabela carteiras
    execute "CREATE TABLE carteiras (
      id INT AUTO_INCREMENT PRIMARY KEY,
      tipo_beneficio ENUM('food', 'meal', 'cash') NOT NULL,
      descricao VARCHAR(255),
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )"

    # Tabela contas_carteiras
    execute "CREATE TABLE contas_carteiras (
      id INT AUTO_INCREMENT PRIMARY KEY,
      conta_id INT NOT NULL,
      carteira_id INT NOT NULL,
      saldo DECIMAL(10, 2) NOT NULL,
      saldo_reservado DECIMAL(18,2) NOT NULL DEFAULT 0.00,
      atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      ativo BOOLEAN NOT NULL DEFAULT TRUE,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (conta_id) REFERENCES contas(id),
      FOREIGN KEY (carteira_id) REFERENCES carteiras(id)
    )"

    # Tabela mccs
    execute "CREATE TABLE mccs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      codigo_mcc VARCHAR(255) NOT NULL UNIQUE,
      nome_estabelecimento VARCHAR(255) NOT NULL,
      permite_food BOOLEAN NOT NULL DEFAULT FALSE,
      permite_meal BOOLEAN NOT NULL DEFAULT FALSE,
      permite_cash BOOLEAN NOT NULL DEFAULT FALSE,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )"

    # Tabela extratos
    execute "CREATE TABLE extratos (
      id INT AUTO_INCREMENT PRIMARY KEY,
      debito DECIMAL(10, 2),
      credito DECIMAL(10, 2),
      id_conta INT NOT NULL,
      data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      descricao VARCHAR(255),
      carteira_id INT NOT NULL,
      FOREIGN KEY (id_conta) REFERENCES contas(id),
      FOREIGN KEY (carteira_id) REFERENCES carteiras(id)
    )"

    # Tabela transacoes
    execute "CREATE TABLE transacoes (
      id INT AUTO_INCREMENT PRIMARY KEY,
      conta_id INT NOT NULL,
      carteira_id INT NOT NULL,
      tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('debito', 'credito')),
      valor DECIMAL(18,2) NOT NULL CHECK (valor > 0),
      status VARCHAR(10) NOT NULL CHECK (status IN ('pendente', 'confirmado', 'cancelado')),
      estabelecimento VARCHAR(255),
      mcc_codigo VARCHAR(255),
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (conta_id) REFERENCES contas(id),
      FOREIGN KEY (carteira_id) REFERENCES carteiras(id)
    )"

    # Tabela estabelecimentos
    execute "CREATE TABLE estabelecimentos (
      uuid CHAR(36) PRIMARY KEY,
      nome_estabelecimento VARCHAR(255) NOT NULL,
      senha_hash VARCHAR(255) NOT NULL,
      criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )"
  end
end
