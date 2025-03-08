defmodule Caju.Mccs do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "mccs" do
    field :codigo_mcc, :string
    field :nome_estabelecimento, :string
    field :permite_food, :boolean, default: false
    field :permite_meal, :boolean, default: false
    field :permite_cash, :boolean, default: false
    field :criado_em, :naive_datetime
  end

  @doc false
  def changeset(mcc, attrs) do
    mcc
    |> cast(attrs, [
      :codigo_mcc,
      :nome_estabelecimento,
      :permite_food,
      :permite_meal,
      :permite_cash
    ])
    |> validate_required([:codigo_mcc, :nome_estabelecimento])
    |> unique_constraint(:codigo_mcc)
  end
end
