defmodule Caju.ContasCarteiras do
  @moduledoc """
  Esquema Ecto para a tabela de associação entre contas e carteiras.

  Este módulo representa a associação entre uma conta de usuário e um tipo
  de carteira específica, mantendo o saldo disponível para cada combinação.

  A tabela contas_carteiras implementa uma relação muitos-para-muitos entre
  contas e carteiras, permitindo que um usuário tenha múltiplas carteiras
  (alimentação, refeição, dinheiro) cada uma com seu próprio saldo.

  O campo `saldo_reservado` é essencial para o mecanismo de reserva de saldo
  que evita condições de corrida durante o processamento de transações.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela contas_carteiras.

  ## Campos

    * `saldo` - Saldo total da carteira
    * `saldo_reservado` - Saldo reservado para transações em processamento
    * `ativo` - Indica se a associação está ativa
    * `atualizado_em` - Data e hora da última atualização
    * `criado_em` - Data e hora de criação do registro
    * `conta_id` - Chave estrangeira para a conta
    * `carteira_id` - Chave estrangeira para a carteira

  ## Associações

    * `conta` - Pertence a uma conta
    * `carteira` - Pertence a uma carteira
  """
  schema "contas_carteiras" do
    field :saldo, :decimal
    field :saldo_reservado, :decimal, default: Decimal.new("0.00")

    field :ativo, :boolean
    field :atualizado_em, :naive_datetime
    field :criado_em, :naive_datetime

    belongs_to :conta, Caju.Contas, foreign_key: :conta_id

    belongs_to :carteira, Caju.Carteiras,
      foreign_key: :carteira_id,
      references: :id,
      type: :integer
  end

  @doc """
  Cria um changeset para validação e persistência de associações conta-carteira.

  Valida a presença dos campos obrigatórios e a existência das entidades
  relacionadas (conta e carteira).

  ## Parâmetros

    * `contas_carteiras` - Struct da associação existente ou nova
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(contas_carteiras, attrs) do
    contas_carteiras
    |> cast(attrs, [:conta_id, :carteira_id, :saldo, :saldo_reservado, :ativo])
    |> validate_required([:conta_id, :carteira_id, :saldo, :ativo])
    |> assoc_constraint(:conta)
    |> assoc_constraint(:carteira)
  end
end
