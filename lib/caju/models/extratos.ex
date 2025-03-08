defmodule Caju.Extratos do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "extratos" do
    field :debito, :decimal
    field :credito, :decimal
    field :data_transacao, :naive_datetime
    field :descricao, :string

    belongs_to :conta, Caju.Contas, foreign_key: :id_conta
    belongs_to :carteira, Caju.Carteiras, foreign_key: :carteira_id, references: :id
  end

  @doc false
  def changeset(extrato, attrs) do
    extrato
    |> cast(attrs, [:debito, :credito, :id_conta, :carteira_id, :data_transacao, :descricao])
    |> validate_required([:id_conta, :carteira_id, :data_transacao])
    |> assoc_constraint(:conta)
    |> assoc_constraint(:carteira)
  end
end
