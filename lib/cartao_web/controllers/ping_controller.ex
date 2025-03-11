defmodule CartaoWeb.PingController do
  @moduledoc """
  Controller simples para verificação de disponibilidade da API.

  Este módulo fornece um endpoint de teste que pode ser usado
  para verificar se a API está funcionando corretamente, sem
  necessidade de autenticação.
  """

  use CartaoWeb, :controller

  @doc """
  Endpoint para teste de disponibilidade da API.

  Retorna uma resposta simples para confirmar que a API está online.
  Este endpoint não requer autenticação.

  ## Rota

    GET /teste/ping

  ## Retorno

  ```json
  {
    "message": "pong"
  }
  ```
  """
  def index(conn, _params) do
    json(conn, %{message: "pong"})
  end
end
