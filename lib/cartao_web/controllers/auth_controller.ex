defmodule CartaoWeb.AuthController do
  @moduledoc """
  Controller responsável pela autenticação de estabelecimentos.

  Este módulo gerencia as requisições HTTP relacionadas à autenticação,
  permitindo que estabelecimentos comerciais obtenham tokens JWT
  para acesso às demais funcionalidades da API.

  Também inclui a documentação Swagger do endpoint para facilitar o uso da API.
  """

  use CartaoWeb, :controller
  use PhoenixSwagger

  alias Cartao.Services.EstabelecimentosService
  alias Cartao.Guardian

  swagger_path :login do
    post("/auth/login")
    summary("Autenticação de estabelecimento")

    description("""
    Autentica um estabelecimento usando UUID e senha. Retorna um token JWT com tempo de expiração de 1 minuto.

    Exemplo de requisição:
    GET /auth/login?uuid=fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea&senha=senha_secreta
    """)

    parameters do
      uuid(:query, :string, "UUID do estabelecimento", required: true)
      senha(:query, :string, "Senha do estabelecimento", required: true)
    end

    response(200, "Success", Schema.ref(:AuthResponse))
    response(401, "Credenciais inválidas")
  end

  def swagger_definitions do
    %{
      AuthResponse:
        swagger_schema do
          title("Resposta de Autenticação")
          description("Resposta contendo o token JWT")

          properties do
            token(:string, "Token JWT para autenticação", required: true)
          end

          example(%{
            token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
          })
        end
    }
  end

  @doc """
  Autentica um estabelecimento e retorna um token JWT.

  Este endpoint valida as credenciais do estabelecimento (UUID e senha)
  e, se corretas, gera um token JWT com validade de 1 minuto para uso
  nas demais operações da API.

  ## Parâmetros (via query string)

    * `uuid` - UUID do estabelecimento
    * `senha` - Senha do estabelecimento

  ## Retorno

  Em caso de sucesso (status 200):
  ```json
  {
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
  }
  ```

  Em caso de erro (status 401):
  ```json
  {
    "error": "Invalid credentials"
  }
  ```
  """
  def login(conn, %{"uuid" => uuid, "senha" => senha}) do
    case EstabelecimentosService.autenticar(uuid, senha) do
      {:ok, estabelecimento} ->
        claims = %{
          "nome" => estabelecimento.nome_estabelecimento,
          "uuid" => estabelecimento.uuid
        }

        case Guardian.encode_and_sign(estabelecimento, claims, ttl: {122, :minutes}) do
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
