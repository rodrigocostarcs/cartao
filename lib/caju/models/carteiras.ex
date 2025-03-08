defmodule Caju.Carteiras do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "carteiras" do
    field :tipo_beneficio, Ecto.Enum, values: [:food, :meal, :cash]
    field :descricao, :string
    field :criado_em, :naive_datetime
  end

  @doc false
  def changeset(carteira, attrs) do
    carteira
    |> cast(attrs, [:tipo_beneficio, :descricao])
    |> validate_required([:tipo_beneficio, :descricao])
    |> validate_inclusion(:tipo_beneficio, [:food, :meal, :cash])
  end
end
