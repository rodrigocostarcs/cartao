defmodule Cartao.Contas do
  @moduledoc """
  Esquema Ecto para a tabela de contas de usuários no banco de dados.

  Este módulo representa as contas dos usuários (beneficiários) no sistema,
  que são associadas a uma ou mais carteiras. Cada conta possui um número
  único e identifica um usuário específico que pode realizar transações.

  As contas são o ponto central de associação para carteiras, transações
  e extratos no sistema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela contas.

  ## Campos

    * `numero_conta` - Número único da conta do usuário
    * `nome_titular` - Nome do titular da conta
    * `criado_em` - Data e hora de criação do registro
  """
  schema "contas" do
    field :numero_conta, :string
    field :nome_titular, :string
    field :criado_em, :naive_datetime
  end

  @doc """
  Cria um changeset para validação e persistência de contas.

  Valida a presença dos campos obrigatórios e a unicidade do número da conta.

  ## Parâmetros

    * `conta` - Struct da conta existente ou nova
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(conta, attrs) do
    conta
    |> cast(attrs, [:numero_conta, :nome_titular])
    |> validate_required([:numero_conta, :nome_titular])
    |> unique_constraint(:numero_conta, name: :contas_numero_conta_index)
  end

  # Jason.Encoder para serialização JSON
  defimpl Jason.Encoder, for: Cartao.Contas do
    @doc """
    Implementação do protocolo Jason.Encoder para serialização JSON.

    Define quais campos da conta são incluídos na serialização para JSON.

    ## Parâmetros

      * `conta` - A conta a ser serializada
      * `opts` - Opções de codificação

    ## Retorno

      * JSON serializado com os campos selecionados
    """
    def encode(%Cartao.Contas{} = conta, opts) do
      conta
      |> Map.take([:id, :nome_titular, :numero_conta, :criado_em])
      |> Jason.Encode.map(opts)
    end
  end
end
