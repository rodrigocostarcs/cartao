defmodule Caju.CarteirasMccs do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "carteiras_mccs" do
    field :criado_em, :naive_datetime

    belongs_to :carteira, Caju.Carteiras, foreign_key: :carteira_id, references: :id_carteira
    belongs_to :mcc, Caju.Mccs, foreign_key: :mcc_id
  end

  @doc false
  def changeset(carteiras_mccs, attrs) do
    carteiras_mccs
    |> cast(attrs, [:carteira_id, :mcc_id])
    |> validate_required([:carteira_id, :mcc_id])
    |> assoc_constraint(:carteira)
    |> assoc_constraint(:mcc)
  end
end
