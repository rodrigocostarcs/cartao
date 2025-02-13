defmodule Caju.Mccs do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "mccs" do
    field :codigo_mcc, :string
    field :nome_estabelecimento, :string
  end

  @doc false
  def changeset(mcc, attrs) do
    mcc
    |> cast(attrs, [:codigo_mcc, :nome_estabelecimento])
    |> validate_required([:codigo_mcc, :nome_estabelecimento])
  end
end
