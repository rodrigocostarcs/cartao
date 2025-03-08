defmodule CajuWeb.PingControllerTest do
  use CajuWeb.ConnCase

  describe "GET /teste/ping" do
    test "retorna mensagem de pong", %{conn: conn} do
      conn = get(conn, ~p"/teste/ping")
      assert json_response(conn, 200) == %{"message" => "pong"}
    end
  end
end
