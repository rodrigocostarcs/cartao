defmodule CajuWeb.TransacaoControllerTest do
  use CajuWeb.ConnCase

  import Plug.Conn
  alias Caju.Repo
  alias Caju.ContasCarteiras
  alias Caju.Guardian

  setup %{conn: conn} do
    conta =
      %Caju.Contas{
        nome_titular: "Rodrigo Costa",
        numero_conta: "123456",
        criado_em: ~N[2025-02-14 10:57:06]
      }
      |> Repo.insert!()

    carteira =
      %Caju.Carteiras{
        tipo_beneficio: :cash,
        descricao: "Benefício Dinheiro",
        criado_em: ~N[2025-02-14 10:57:06]
      }
      |> Repo.insert!()

    _conta_carteira =
      %ContasCarteiras{
        conta_id: conta.id,
        carteira_id: carteira.id,
        saldo: Decimal.new("3000.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true,
        criado_em: ~N[2025-02-14 10:57:06],
        atualizado_em: ~N[2025-02-14 10:57:06]
      }
      |> Repo.insert!()

    estabelecimento =
      %Caju.Estabelecimentos{
        nome_estabelecimento: "Estabelecimento Exemplo",
        senha_hash:
          "$pbkdf2-sha512$160000$/CrIInlvYGHTbkQQ2H8jaQ$0GhMgH2tWaypbZfGGy5AKUviZTBeo9Yd4VHZQyKtWhmuFZG/4CMxowQMMJGFh5lLIThBzr7qOIX2aPS.bQ120w",
        uuid: "fa1b48ca-4eee-44db-9e6a-37cf4d58f1ea"
      }
      |> Repo.insert!()

    # Gerar token JWT para autenticação
    {:ok, token, _claims} = Guardian.encode_and_sign(estabelecimento, %{}, ttl: {30, :minutes})

    # Adicionar token de autenticação ao conn
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> put_req_header("content-type", "application/json")

    {:ok, conn: conn, estabelecimento: estabelecimento, conta: conta}
  end

  describe "POST /api/efetivar/transacao" do
    test "processa transação bem-sucedida", %{conn: conn, estabelecimento: estabelecimento} do
      payload = %{
        "conta" => "123456",
        "valor" => 100.00,
        "mcc" => "5411",
        "estabelecimento" => estabelecimento.nome_estabelecimento
      }

      conn = post(conn, "/api/efetivar/transacao", payload)
      response = json_response(conn, 200)
      assert response["code"] == "00"
    end

    test "retorna código de erro quando não há saldo suficiente", %{
      conn: conn,
      estabelecimento: estabelecimento
    } do
      payload = %{
        "conta" => "123456",
        "valor" => 5000.00,
        "mcc" => "5411",
        "estabelecimento" => estabelecimento.nome_estabelecimento
      }

      conn = post(conn, "/api/efetivar/transacao", payload)
      response = json_response(conn, 200)
      # Código "51" indica saldo insuficiente
      assert response["code"] == "51"
    end

    test "processa transação com MCC inexistente usando fallback", %{conn: conn} do
      payload = %{
        "conta" => "123456",
        "valor" => 100.00,
        "mcc" => "9999",
        "estabelecimento" => "Loja Inexistente"
      }

      conn = post(conn, "/api/efetivar/transacao", payload)
      response = json_response(conn, 200)
      assert response["code"] == "00"
    end

    test "retorna código genérico para conta inexistente", %{conn: conn} do
      payload = %{
        "conta" => "conta_inexistente",
        "valor" => 100.00,
        "mcc" => "5411",
        "estabelecimento" => "Estabelecimento Teste"
      }

      conn = post(conn, "/api/efetivar/transacao", payload)
      response = json_response(conn, 200)
      # Quando a conta não é encontrada, o controller retorna código "07"
      assert response["code"] == "07"
    end
  end
end
