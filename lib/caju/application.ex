defmodule Caju.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CajuWeb.Telemetry,
      # Start the Ecto repository
      Caju.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Caju.PubSub},
      # Start Finch
      {Finch, name: Caju.Finch},
      # Start the Endpoint (http/https)
      CajuWeb.Endpoint
      # Start a worker by calling: Caju.Worker.start_link(arg)
      # {Caju.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Caju.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CajuWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
