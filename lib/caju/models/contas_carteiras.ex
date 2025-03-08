defmodule Caju.ContasCarteiras do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

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

  @doc false
  def changeset(contas_carteiras, attrs) do
    contas_carteiras
    |> cast(attrs, [:conta_id, :carteira_id, :saldo, :saldo_reservado, :ativo])
    |> validate_required([:conta_id, :carteira_id, :saldo, :ativo])
    |> assoc_constraint(:conta)
    |> assoc_constraint(:carteira)
  end
end
