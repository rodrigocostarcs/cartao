defmodule Cartao.Guardian.AuthPipeline do
  @moduledoc """
  Pipeline de autenticação para rotas protegidas da API.

  Este módulo define o pipeline de autenticação baseado em tokens JWT,
  que é utilizado nas rotas que exigem autenticação prévia. O pipeline
  inclui:

  1. Verificação do token JWT no cabeçalho Authorization
  2. Garantia de que o token é válido e não expirou
  3. Carregamento do recurso (estabelecimento) associado ao token

  É aplicado via pipe_through [:api, :auth] no router
  para as rotas que necessitam de autenticação.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :cartao,
    module: Cartao.Guardian,
    error_handler: CartaoWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
