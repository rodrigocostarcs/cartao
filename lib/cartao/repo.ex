defmodule Cartao.Repo do
  use Ecto.Repo,
    otp_app: :cartao,
    adapter: Ecto.Adapters.MyXQL
end
