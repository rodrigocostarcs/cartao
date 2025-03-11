defmodule CartaoWeb.Router do
  use CartaoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CartaoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Cartao.Guardian.AuthPipeline
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :cartao,
      swagger_file: "swagger.json"
  end

  scope "/api", CartaoWeb do
    pipe_through [:api, :auth]

    post "/efetivar/transacao", TransacaoController, :efetivar_transacao
    get "/consultar/saldo", SaldoController, :consultar_saldo
  end

  scope "/auth", CartaoWeb do
    pipe_through :api
    post "/login", AuthController, :login
  end

  scope "/teste", CartaoWeb do
    pipe_through :api
    get "/ping", PingController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CartaoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:cartao, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev", CartaoWeb do
      pipe_through :browser

      get "/", PageController, :home
      live_dashboard "/dashboard", metrics: CartaoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "API Cartao",
        description:
          "API para processamento de transações financeiras com diferentes tipos de carteiras.",
        termsOfService: "https://www.escrevendocodigos.com/termos",
        contact: %{
          name: "xxxx xxx",
          email: "xxx@xxx.com.br"
        }
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          in: "header",
          description: "Token JWT no formato: Bearer {token}"
        }
      }
    }
  end
end
