defmodule CajuWeb.Router do
  use CajuWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CajuWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Caju.Guardian.AuthPipeline
  end

  scope "/api", CajuWeb do
    pipe_through [:api, :auth]

    post "/efetivar/transacao", TransacaoController, :efetivar_transacao
  end

  scope "/auth", CajuWeb do
    pipe_through :api
    post "/login", AuthController, :login
  end

  scope "/teste", CajuWeb do
    pipe_through :api
    get "/ping", PingController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CajuWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:caju, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev", CajuWeb do
      pipe_through :browser

      get "/", PageController, :home
      live_dashboard "/dashboard", metrics: CajuWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
