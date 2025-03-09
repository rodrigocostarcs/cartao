defmodule CajuWeb.AuthErrorHandler do
  @moduledoc """
  Manipulador de erros de autenticação para a API.

  Este módulo é responsável por tratar erros que ocorrem durante
  o processo de autenticação, formatando as respostas de erro
  para os clientes da API de maneira padronizada.

  É utilizado pelo pipeline de autenticação Guardian para
  converter erros de autenticação em respostas HTTP apropriadas.
  """

  import Plug.Conn

  @doc """
  Manipula erros de autenticação e formata a resposta HTTP.

  ## Parâmetros

    * `conn` - Conexão Plug
    * `{type, _reason}` - Tipo e motivo do erro de autenticação
    * `_opts` - Opções adicionais (não utilizadas)

  ## Retorno

  Resposta HTTP com status 401 e corpo JSON contendo a mensagem de erro.

  Exemplo:
  ```json
  {
    "error": "unauthenticated"
  }
  ```
  """
  @spec auth_error(Plug.Conn.t(), {atom(), any()}, any()) :: Plug.Conn.t()
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    send_resp(conn, 401, body)
  end
end
