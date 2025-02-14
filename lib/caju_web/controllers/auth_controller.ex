defmodule CajuWeb.AuthController do
  use CajuWeb, :controller
  alias Caju.Services.EstabelecimentosService
  alias Caju.Guardian

  def login(conn, %{"uuid" => uuid, "senha" => senha}) do
    case EstabelecimentosService.authenticate(uuid, senha) do
      {:ok, estabelecimento} ->
        claims = %{
          "nome" => estabelecimento.nome_estabelecimento,
          "uuid" => estabelecimento.uuid
        }

        case Guardian.encode_and_sign(estabelecimento, claims, ttl: {1, :minutes}) do
          {:ok, token, _claims} ->
            json(conn, %{
              token: token
            })

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to generate token: #{reason}"})
        end

      :error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
