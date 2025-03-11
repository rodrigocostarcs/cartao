defmodule Cartao.Carteiras do
  @moduledoc """
  Esquema Ecto para a tabela de carteiras no banco de dados.

  Este módulo representa os tipos de carteiras disponíveis no sistema:
  - `:food`: Carteira de alimentação, para uso em supermercados e estabelecimentos similares
  - `:meal`: Carteira de refeição, para uso em restaurantes e estabelecimentos similares
  - `:cash`: Carteira de dinheiro, para uso geral

  Cada tipo de carteira está associado a regras específicas de MCC (Merchant Category Code)
  que determinam onde pode ser utilizada para transações.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela carteiras.

  ## Campos

    * `tipo_beneficio` - Enum que define o tipo da carteira (:food, :meal, :cash)
    * `descricao` - Descrição textual da carteira
    * `criado_em` - Data e hora de criação do registro
  """
  schema "carteiras" do
    field :tipo_beneficio, Ecto.Enum, values: [:food, :meal, :cash]
    field :descricao, :string
    field :criado_em, :naive_datetime
  end

  @doc """
  Cria um changeset para validação e persistência de carteiras.

  Valida que o tipo_beneficio seja um dos valores aceitos (:food, :meal, :cash).

  ## Parâmetros

    * `carteira` - Struct da carteira existente ou nova
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(carteira, attrs) do
    carteira
    |> cast(attrs, [:tipo_beneficio, :descricao])
    |> validate_required([:tipo_beneficio, :descricao])
    |> validate_inclusion(:tipo_beneficio, [:food, :meal, :cash])
  end
end
