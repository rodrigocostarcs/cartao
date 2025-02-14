defmodule Caju.Carteiras do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id_carteira, :integer, [source: :id_carteira]}

  schema "carteiras" do
    field :tipo_beneficio, Ecto.Enum, values: [:food, :meal, :cash]
    field :descricao, :string
    field :criado_em, :naive_datetime

    # Relacionamentos
    has_many :carteiras_mccs, Caju.CarteirasMccs, foreign_key: :carteira_id
    has_many :mccs, through: [:carteiras_mccs, :mcc]
  end

  @doc false
  def changeset(carteira, attrs) do
    carteira
    |> cast(attrs, [:tipo_beneficio, :descricao])
    |> validate_required([:tipo_beneficio, :descricao])
    |> validate_inclusion(:tipo_beneficio, in: [:food, :meal, :cash])
  end
end
