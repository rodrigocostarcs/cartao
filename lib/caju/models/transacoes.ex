defmodule Caju.Transacoes do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "transacoes" do
    field :tipo, :string
    field :valor, :decimal
    field :status, :string
    field :estabelecimento, :string
    field :mcc_codigo, :string
    field :criado_em, :naive_datetime

    belongs_to :conta, Caju.Contas, foreign_key: :conta_id
    belongs_to :carteira, Caju.Carteiras, foreign_key: :carteira_id, references: :id_carteira
  end

  @doc false
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
