defmodule CajuWeb.ContasController do
  use CajuWeb, :controller
  alias Caju.ContasServices

  def pegar_conta(conn, %{"id" => id}) do
    with {:ok, conta} <- ContasServices.pegar_conta_por_id(id) do
      json(conn, conta)
    else
      :error -> send_resp(conn, 404, "")
      :no_content -> send_resp(conn, 204, "")
    end
  end
end
