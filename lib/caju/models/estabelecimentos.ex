defmodule Caju.Estabelecimentos do
  @moduledoc """
  Esquema Ecto para a tabela de estabelecimentos comerciais.

  Este módulo representa os estabelecimentos comerciais que utilizam
  a API para processar transações financeiras. Cada estabelecimento
  é identificado por um UUID único e possui credenciais de autenticação
  (senha hash) para obter tokens JWT.

  Os estabelecimentos são responsáveis por iniciar as transações
  financeiras que debitam as carteiras dos usuários.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Pbkdf2

  @primary_key {:uuid, :string, autogenerate: false}

  @doc """
  Define o esquema da tabela estabelecimentos.

  ## Campos

    * `uuid` - Identificador único universal (chave primária)
    * `nome_estabelecimento` - Nome do estabelecimento comercial
    * `senha` - Campo virtual para a senha (não armazenada no banco)
    * `senha_hash` - Hash da senha para autenticação
  """
  schema "estabelecimentos" do
    field :nome_estabelecimento, :string
    field :senha, :string, virtual: true
    field :senha_hash, :string
  end

  @doc """
  Cria um changeset para validação e persistência de estabelecimentos.

  Valida a presença dos campos obrigatórios e gera o hash da senha
  quando uma nova senha é fornecida.

  ## Parâmetros

    * `estabelecimento` - Struct do estabelecimento existente ou novo
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(estabelecimento, attrs) do
    estabelecimento
    |> cast(attrs, [:uuid, :nome_estabelecimento, :senha])
    |> validate_required([:uuid, :nome_estabelecimento, :senha])
    |> put_pass_hash()
  end

  @doc false
  defp put_pass_hash(changeset) do
    case get_change(changeset, :senha) do
      nil -> changeset
      senha -> put_change(changeset, :senha_hash, Pbkdf2.hash_pwd_salt(senha))
    end
  end
end
