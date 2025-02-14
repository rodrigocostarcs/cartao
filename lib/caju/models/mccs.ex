defmodule Caju.Mccs do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "mccs" do
    field :codigo_mcc, :string
    field :nome_estabelecimento, :string

    has_many :carteiras_mccs, Caju.CarteirasMccs, foreign_key: :mcc_id
    has_many :carteiras, through: [:carteiras_mccs, :carteira]
  end

  @doc false
  def changeset(mcc, attrs) do
    mcc
    |> cast(attrs, [:codigo_mcc, :nome_estabelecimento])
    |> validate_required([:codigo_mcc, :nome_estabelecimento])
  end
end
