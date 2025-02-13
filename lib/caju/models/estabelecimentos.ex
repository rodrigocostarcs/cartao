defmodule Caju.Estabelecimentos do
  use Ecto.Schema
  import Ecto.Changeset
  alias Pbkdf2

  @primary_key {:uuid, :string, autogenerate: false}
  schema "estabelecimentos" do
    field :nome_estabelecimento, :string
    field :senha, :string, virtual: true
    field :senha_hash, :string
  end

  @doc false
  def changeset(estabelecimento, attrs) do
    estabelecimento
    |> cast(attrs, [:uuid, :nome_estabelecimento, :senha])
    |> validate_required([:uuid, :nome_estabelecimento, :senha])
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case get_change(changeset, :senha) do
      nil -> changeset
      senha -> put_change(changeset, :senha_hash, Pbkdf2.hash_pwd_salt(senha))
    end
  end
end
