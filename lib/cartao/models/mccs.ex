defmodule Cartao.Mccs do
  @moduledoc """
  Esquema Ecto para a tabela de MCCs (Merchant Category Codes).

  Este módulo representa os códigos de categoria de estabelecimentos comerciais (MCCs),
  que são fundamentais para a lógica de direcionamento de transações para os
  tipos apropriados de carteira.

  Cada MCC possui flags que indicam quais tipos de carteira podem ser utilizados:
  - `permite_food`: Permite uso da carteira de alimentação
  - `permite_meal`: Permite uso da carteira de refeição
  - `permite_cash`: Permite uso da carteira de dinheiro

  Estas regras determinam qual carteira será utilizada durante o processamento
  de uma transação em um determinado tipo de estabelecimento.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}

  @doc """
  Define o esquema da tabela mccs.

  ## Campos

    * `codigo_mcc` - Código MCC padrão da indústria (ex: "5411" para supermercados)
    * `nome_estabelecimento` - Nome do tipo de estabelecimento
    * `permite_food` - Flag que indica se permite carteira de alimentação
    * `permite_meal` - Flag que indica se permite carteira de refeição
    * `permite_cash` - Flag que indica se permite carteira de dinheiro
    * `criado_em` - Data e hora de criação do registro
  """
  schema "mccs" do
    field :codigo_mcc, :string
    field :nome_estabelecimento, :string
    field :permite_food, :boolean, default: false
    field :permite_meal, :boolean, default: false
    field :permite_cash, :boolean, default: false
    field :criado_em, :naive_datetime
  end

  @doc """
  Cria um changeset para validação e persistência de MCCs.

  Valida a presença dos campos obrigatórios e a unicidade do código MCC.

  ## Parâmetros

    * `mcc` - Struct do MCC existente ou novo
    * `attrs` - Atributos para atualização ou criação

  ## Retorno

    * Changeset válido ou inválido com erros
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
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
