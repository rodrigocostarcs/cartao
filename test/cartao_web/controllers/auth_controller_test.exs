defmodule CartaoWeb.AuthControllerTest do
  use CartaoWeb.ConnCase

  alias Cartao.Repo
  alias Pbkdf2

  setup %{conn: conn} do
    # Criar estabelecimento para teste
    {:ok, estabelecimento} =
      Repo.insert(%Cartao.Estabelecimentos{
        uuid: "test-uuid-123",
        nome_estabelecimento: "Estabelecimento Teste",
        senha_hash: Pbkdf2.hash_pwd_salt("senha_teste")
      })

    {:ok, conn: conn, estabelecimento: estabelecimento}
  end

  describe "POST /auth/login" do
    test "login bem-sucedido retorna token", %{conn: conn} do
      conn = post(conn, "/auth/login?uuid=test-uuid-123&senha=senha_teste")

      response = json_response(conn, 200)
      assert Map.has_key?(response, "token")
      assert is_binary(response["token"])
    end

    test "login com credenciais inválidas retorna erro", %{conn: conn} do
      conn = post(conn, "/auth/login?uuid=test-uuid-123&senha=senha_errada")

      response = json_response(conn, 401)
      assert response == %{"error" => "Invalid credentials"}
    end

    test "login com uuid inexistente retorna erro", %{conn: conn} do
      conn = post(conn, "/auth/login?uuid=uuid-inexistente&senha=senha_teste")

      response = json_response(conn, 401)
      assert response == %{"error" => "Invalid credentials"}
    end
  end
end
