defmodule CajuWeb.PingController do
  use CajuWeb, :controller

  def index(conn, _params) do
    json(conn, %{message: "pong"})
  end
end
