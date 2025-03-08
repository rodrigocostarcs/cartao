defmodule CajuWeb.TransacaoController do
  use CajuWeb, :controller
  use PhoenixSwagger

  alias Caju.Services.TransacaoService

  swagger_path :efetivar_transacao do
    post("/api/efetivar/transacao")
    summary("Efetua uma transação financeira")

    description("""
    Processa uma transação financeira usando o número da conta, valor, código MCC e nome do estabelecimento.

    Exemplos de requisições:

    1. Aprovação com carteira de alimentação:
       { "conta": "123456", "valor": 100.00, "mcc": "5411", "estabelecimento": "Supermercado A" }

    2. Aprovação com carteira de refeição:
       { "conta": "789012", "valor": 100.00, "mcc": "5811", "estabelecimento": "Restaurante A" }

    3. Aprovação com carteira cash (MCC não mapeado):
       { "conta": "789012", "valor": 100.00, "mcc": "58191", "estabelecimento": "Loja jp" }

    4. Rejeição por saldo insuficiente:
       { "conta": "789012", "valor": 2900.00, "mcc": "581911", "estabelecimento": "Restaurante A" }

    5. Sem saldo na carteira Meal, usando Cash:
       { "conta": "789012", "valor": 2800.01, "mcc": "5811", "estabelecimento": "Supermercado B" }

    6. Mapear por estabelecimento:
       { "conta": "789012", "valor": 0.55, "mcc": "581911", "estabelecimento": "Restaurante A" }

    7. Erro quando conta inexistente:
       { "conta": "78901200", "valor": 2900, "mcc": "581911", "estabelecimento": "Restaurante A" }
    """)

    security([%{Bearer: []}])
    consumes("application/json")
    produces("application/json")

    parameters do
      body(:body, Schema.ref(:TransacaoParams), "Parâmetros da transação", required: true)
    end

    response(200, "Transação processada", Schema.ref(:TransacaoResponse))
    response(401, "Não autorizado")
  end

  def swagger_definitions do
    %{
      TransacaoParams:
        swagger_schema do
          title("Parâmetros da Transação")
          description("Parâmetros necessários para efetuar uma transação")

          properties do
            conta(:string, "Número da conta", required: true)
            valor(:number, "Valor da transação", required: true, format: :float)
            mcc(:string, "Código MCC do estabelecimento", required: true)
            estabelecimento(:string, "Nome do estabelecimento", required: true)
          end

          example(%{
            conta: "123456",
            valor: 100.00,
            mcc: "5411",
            estabelecimento: "Supermercado A"
          })
        end,
      TransacaoResponse:
        swagger_schema do
          title("Resposta da Transação")
          description("Resposta da transação com o código de retorno")

          properties do
            code(:string, "Código de resposta (00=Aprovada, 51=Saldo insuficiente, 07=Erro)",
              required: true
            )
          end

          example(%{
            code: "00"
          })
        end
    }
  end

  def efetivar_transacao(conn, %{
        "conta" => conta,
        "valor" => valor,
        "mcc" => mcc,
        "estabelecimento" => estabelecimento
      }) do
    case TransacaoService.buscar_carteira_por_conta(conta) do
      {:ok, carteiras} ->
        code =
          TransacaoService.efetivar_transacao(carteiras, valor, mcc, estabelecimento)
          |> pegar_codigo_transacao()

        conn
        |> put_status(:ok)
        |> json(%{code: code})

      {:error, _error} ->
        conn
        |> put_status(:ok)
        |> json(%{code: "07"})
    end
  end

  defp pegar_codigo_transacao(retorno_transacao) do
    case retorno_transacao do
      {:ok, {:ok, code}} -> code
      {:error, :saldo_insuficiente} -> "51"
    end
  end
end
