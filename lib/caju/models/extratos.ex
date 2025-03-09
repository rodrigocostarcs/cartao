defmodule Caju.Extratos do
  @moduledoc """
  Esquema Ecto para a tabela de extratos de transações.

  Este módulo representa o histórico detalhado de movimentações financeiras
  nas carteiras dos usuários. Cada registro de extrato documenta uma operação
  de débito ou crédito, mantendo a trilha de auditoria completa das transações.

  Os extratos são essenciais para rastreabilidade das operações e para
  apresentação do histórico de movimentações para os usuários.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela extratos.

  ## Campos

    * `debito` - Valor debitado (quando aplicável)
    * `credito` - Valor creditado (quando aplicável)
    * `data_transacao` - Data e hora da transação
    * `descricao` - Descrição textual da transação
    * `id_conta` - Chave estrangeira para a conta
    * `carteira_id` - Chave estrangeira para a carteira

  ## Associações

    * `conta` - Pertence a uma conta
    * `carteira` - Pertence a uma carteira
  """
  schema "extratos" do
    field :debito, :decimal
    field :credito, :decimal
    field :data_transacao, :naive_datetime
    field :descricao, :string

    belongs_to :conta, Caju.Contas, foreign_key: :id_conta
    belongs_to :carteira, Caju.Carteiras, foreign_key: :carteira_id, references: :id
  end

  @doc """
  Cria um changeset para validação e persistência de extratos.

  Valida a presença dos campos obrigatórios e a existência das entidades
  relacionadas (conta e carteira).

  ## Parâmetros

    * `extrato` - Struct do extrato existente ou novo
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(extrato, attrs) do
    extrato
    |> cast(attrs, [:debito, :credito, :id_conta, :carteira_id, :data_transacao, :descricao])
    |> validate_required([:id_conta, :carteira_id, :data_transacao])
    |> assoc_constraint(:conta)
    |> assoc_constraint(:carteira)
  end
end
