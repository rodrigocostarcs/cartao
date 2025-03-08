defmodule Caju.Contas do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  schema "contas" do
    field :numero_conta, :string
    field :nome_titular, :string
    field :criado_em, :naive_datetime
  end

  @doc false
  def changeset(conta, attrs) do
    conta
    |> cast(attrs, [:numero_conta, :nome_titular])
    |> validate_required([:numero_conta, :nome_titular])
    |> unique_constraint(:numero_conta, name: :contas_numero_conta_index)
  end

  # Jason.Encoder para serialização JSON
  defimpl Jason.Encoder, for: Caju.Contas do
    def encode(%Caju.Contas{} = conta, opts) do
      conta
      |> Map.take([:id, :nome_titular, :numero_conta, :criado_em])
      |> Jason.Encode.map(opts)
    end
  end
end
