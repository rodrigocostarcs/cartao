defmodule CajuWeb.SaldoControllerTest do
  use CajuWeb.ConnCase

  import Plug.Conn
  alias Caju.Repo
  alias Caju.ContasCarteiras
  alias Caju.Guardian

  setup %{conn: conn} do
    # Criando usuário de teste
    conta =
      %Caju.Contas{
        nome_titular: "Usuário Teste",
        numero_conta: "654321",
        criado_em: ~N[2025-03-08 10:00:00]
      }
      |> Repo.insert!()

    # Criando carteiras
    food_carteira =
      %Caju.Carteiras{
        tipo_beneficio: :food,
        descricao: "Benefício Alimentação",
        criado_em: ~N[2025-03-08 10:00:00]
      }
      |> Repo.insert!()

    meal_carteira =
      %Caju.Carteiras{
        tipo_beneficio: :meal,
        descricao: "Benefício Refeição",
        criado_em: ~N[2025-03-08 10:00:00]
      }
      |> Repo.insert!()

    # Associando carteiras à conta
    %ContasCarteiras{
      conta_id: conta.id,
      carteira_id: food_carteira.id,
      saldo: Decimal.new("1500.00"),
      saldo_reservado: Decimal.new("200.00"),
      ativo: true,
      criado_em: ~N[2025-03-08 10:00:00],
      atualizado_em: ~N[2025-03-08 10:00:00]
    }
    |> Repo.insert!()

    %ContasCarteiras{
      conta_id: conta.id,
      carteira_id: meal_carteira.id,
      saldo: Decimal.new("800.00"),
      saldo_reservado: Decimal.new("0.00"),
      ativo: true,
      criado_em: ~N[2025-03-08 10:00:00],
      atualizado_em: ~N[2025-03-08 10:00:00]
    }
    |> Repo.insert!()

    # Criando estabelecimento para autenticação
    estabelecimento =
      %Caju.Estabelecimentos{
        nome_estabelecimento: "Estabelecimento Teste",
        senha_hash: Pbkdf2.hash_pwd_salt("senha_teste"),
        uuid: "test-uuid-saldo-123"
      }
      |> Repo.insert!()

    # Gerando token JWT
    {:ok, token, _claims} = Guardian.encode_and_sign(estabelecimento, %{}, ttl: {30, :minutes})

    # Configurando conn com o token
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok,
     conn: conn,
     estabelecimento: estabelecimento,
     conta: conta,
     food_carteira: food_carteira,
     meal_carteira: meal_carteira}
  end

  describe "GET /api/consultar/saldo" do
    test "retorna saldo da carteira food", %{conn: conn} do
      conn = get(conn, "/api/consultar/saldo?conta=654321&tipo_carteira=food")

      response = json_response(conn, 200)
      assert response["conta_numero"] == "654321"
      assert response["tipo_carteira"] == "food"
      assert response["saldo"] == 1500.0
      assert response["saldo_reservado"] == 200.0
      assert response["saldo_disponivel"] == 1300.0
    end

    test "retorna saldo da carteira meal", %{conn: conn} do
      conn = get(conn, "/api/consultar/saldo?conta=654321&tipo_carteira=meal")

      response = json_response(conn, 200)
      assert response["conta_numero"] == "654321"
      assert response["tipo_carteira"] == "meal"
      assert response["saldo"] == 800.0
      assert response["saldo_reservado"] == 0.0
      assert response["saldo_disponivel"] == 800.0
    end

    test "retorna erro para conta inexistente", %{conn: conn} do
      conn = get(conn, "/api/consultar/saldo?conta=111111&tipo_carteira=food")

      response = json_response(conn, 404)
      assert response["error"] == "Conta não encontrada"
    end

    test "retorna erro para carteira inexistente", %{conn: conn} do
      conn = get(conn, "/api/consultar/saldo?conta=654321&tipo_carteira=cash")

      response = json_response(conn, 404)
      assert response["error"] == "Carteira não encontrada para esta conta"
    end

    test "retorna erro para tipo de carteira inválido", %{conn: conn} do
      conn = get(conn, "/api/consultar/saldo?conta=654321&tipo_carteira=invalid_type")

      response = json_response(conn, 400)
      assert response["error"] == "Tipo de carteira inválido. Use 'food', 'meal' ou 'cash'"
    end
  end
end
