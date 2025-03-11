defmodule Cartao.Guardian do
  @moduledoc """
  Módulo responsável pela geração e validação de tokens JWT.

  Este módulo implementa a integração com o Guardian para autenticação
  baseada em tokens JWT, permitindo:

  - Geração de tokens para estabelecimentos autenticados
  - Validação de tokens em requisições protegidas
  - Extração de informações do estabelecimento a partir do token

  É utilizado pelo pipeline de autenticação para proteger rotas
  que exigem autenticação prévia.
  """

  use Guardian, otp_app: :cartao
  alias Cartao.Services.EstabelecimentosService

  @doc """
  Gera o subject para um token JWT a partir do recurso.

  ## Parâmetros

    * `resource` - Estabelecimento autenticado
    * `_claims` - Claims adicionais (não utilizado)

  ## Retorno

    * `{:ok, sub}` - Subject do token (UUID do estabelecimento)
  """
  @spec subject_for_token(map(), map()) :: {:ok, String.t()}
  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.uuid)}
  end

  @doc """
  Recupera o recurso (estabelecimento) a partir de claims do token.

  ## Parâmetros

    * `claims` - Claims extraídos do token JWT

  ## Retorno

    * `{:ok, estabelecimento}` - Estabelecimento associado ao token
    * `{:error, :resource_not_found}` - Quando o estabelecimento não é encontrado
  """
  @spec resource_from_claims(map()) :: {:ok, map()} | {:error, :resource_not_found}
  def resource_from_claims(%{"sub" => uuid}) do
    case EstabelecimentosService.pegar_estabelecimento_por_uuid(uuid) do
      :no_content -> {:error, :resource_not_found}
      estabelecimento -> {:ok, estabelecimento}
    end
  end
end
