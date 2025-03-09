defmodule CajuWeb.SaldoController do
  use CajuWeb, :controller
  use PhoenixSwagger

  alias Caju.Services.SaldoService

  swagger_path :consultar_saldo do
    get("/api/consultar/saldo")
    summary("Consulta o saldo de uma conta e carteira específica")

    description("""
    Retorna o saldo atual da carteira especificada para a conta informada.

    Exemplos de requisições:

    1. Consulta de saldo de carteira food:
       GET /api/consultar/saldo?conta=123456&tipo_carteira=food

    2. Consulta de saldo de carteira meal:
       GET /api/consultar/saldo?conta=789012&tipo_carteira=meal

    3. Consulta de saldo de carteira cash:
       GET /api/consultar/saldo?conta=789012&tipo_carteira=cash
    """)

    parameters do
      conta(:query, :string, "Número da conta", required: true)
      tipo_carteira(:query, :string, "Tipo da carteira (food, meal, cash)", required: true)
    end

    security([%{Bearer: []}])

    response(200, "Saldo consultado com sucesso", Schema.ref(:SaldoResponse))
    response(404, "Conta ou carteira não encontrada")
    response(400, "Tipo de carteira inválido")
    response(401, "Não autorizado")
  end

  def swagger_definitions do
    %{
      SaldoResponse:
        swagger_schema do
          title("Resposta de Consulta de Saldo")
          description("Detalhes do saldo da carteira solicitada")

          properties do
            conta_numero(:string, "Número da conta", required: true)
            titular(:string, "Nome do titular da conta", required: true)
            tipo_carteira(:string, "Tipo da carteira (food, meal, cash)", required: true)
            saldo(:number, "Saldo disponível", required: true, format: :float)
            saldo_reservado(:number, "Saldo reservado", required: true, format: :float)

            saldo_disponivel(:number, "Saldo total disponível (saldo - saldo_reservado)",
              required: true,
              format: :float
            )
          end

          example(%{
            conta_numero: "123456",
            titular: "João Silva",
            tipo_carteira: "food",
            saldo: 1000.00,
            saldo_reservado: 0.00,
            saldo_disponivel: 1000.00
          })
        end
    }
  end

  def consultar_saldo(conn, %{"conta" => conta, "tipo_carteira" => tipo_carteira}) do
    case SaldoService.consultar_saldo(conta, tipo_carteira) do
      {:ok, saldo_info} ->
        conn
        |> put_status(:ok)
        |> json(saldo_info)

      {:error, :conta_nao_encontrada} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Conta não encontrada"})

      {:error, :carteira_nao_encontrada} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Carteira não encontrada para esta conta"})

      {:error, :tipo_carteira_invalido} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Tipo de carteira inválido. Use 'food', 'meal' ou 'cash'"})
    end
  end
end
