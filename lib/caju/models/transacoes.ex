defmodule Caju.Transacoes do
  @moduledoc """
  Esquema Ecto para a tabela de transações financeiras.

  Este módulo representa o registro centralizado de todas as operações
  financeiras processadas pelo sistema. Cada transação está associada
  a uma conta, uma carteira, um estabelecimento e potencialmente a um MCC.

  As transações podem ser de dois tipos:
  - `debito`: Redução do saldo disponível na carteira
  - `credito`: Aumento do saldo disponível na carteira

  E podem ter diferentes status:
  - `pendente`: Transação em processamento
  - `confirmado`: Transação concluída com sucesso
  - `cancelado`: Transação cancelada ou revertida
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela transacoes.

  ## Campos

    * `tipo` - Tipo da transação ("debito" ou "credito")
    * `valor` - Valor monetário da transação
    * `status` - Status da transação ("pendente", "confirmado" ou "cancelado")
    * `estabelecimento` - Nome do estabelecimento onde ocorreu a transação
    * `mcc_codigo` - Código MCC do estabelecimento
    * `criado_em` - Data e hora de criação do registro
    * `conta_id` - Chave estrangeira para a conta
    * `carteira_id` - Chave estrangeira para a carteira

  ## Associações

    * `conta` - Pertence a uma conta
    * `carteira` - Pertence a uma carteira
  """
  schema "transacoes" do
    field :tipo, :string
    field :valor, :decimal
    field :status, :string
    field :estabelecimento, :string
    field :mcc_codigo, :string
    field :criado_em, :naive_datetime

    belongs_to :conta, Caju.Contas, foreign_key: :conta_id
    belongs_to :carteira, Caju.Carteiras, foreign_key: :carteira_id, references: :id
  end

  @doc """
  Cria um changeset para validação e persistência de transações.

  Valida a presença dos campos obrigatórios, os valores permitidos para
  tipo e status, e que o valor seja positivo.

  ## Parâmetros

    * `transacao` - Struct da transação existente ou nova
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(transacao, attrs) do
    transacao
    |> cast(attrs, [
      :conta_id,
      :carteira_id,
      :tipo,
      :valor,
      :status,
      :estabelecimento,
      :mcc_codigo
    ])
    |> validate_required([:conta_id, :carteira_id, :tipo, :valor, :status])
    |> validate_inclusion(:tipo, ["debito", "credito"])
    |> validate_inclusion(:status, ["pendente", "confirmado", "cancelado"])
    |> validate_number(:valor, greater_than: 0)
    |> assoc_constraint(:conta)
    |> assoc_constraint(:carteira)
  end
end
