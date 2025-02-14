defmodule Caju.Contas do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, [source: :id]}

  schema "contas" do
    field :nome_titular, :string
    field :numero_conta, :string
    field :criado_em, :naive_datetime
  end

  @doc false
  def changeset(conta, attrs) do
    conta
    |> cast(attrs, [:nome_titular, :numero_conta])
    |> validate_required([:nome_titular, :numero_conta])
  end

  defimpl Jason.Encoder, for: Caju.Contas do
    def encode(%Caju.Contas{} = conta, opts) do
      conta
      |> Map.take([:id, :nome_titular, :numero_conta, :criado_em])
      |> Jason.Encode.map(opts)
    end
  end
end
