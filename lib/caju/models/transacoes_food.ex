defmodule Caju.TransacoesFood do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "transacoes_food" do
    field :tipo, :string
    field :valor, :decimal
    field :status, :string
    field :criado_em, :naive_datetime

    belongs_to :conta, Caju.Contas, foreign_key: :conta_id
  end

  @doc false
  def changeset(transacao_food, attrs) do
    transacao_food
    |> cast(attrs, [:conta_id, :tipo, :valor, :status])
    |> validate_required([:conta_id, :tipo, :valor, :status])
    |> validate_inclusion(:tipo, ["debito", "credito"])
    |> validate_inclusion(:status, ["pendente", "confirmado", "cancelado"])
    |> validate_number(:valor, greater_than: 0)
    |> assoc_constraint(:conta)
  end
end
