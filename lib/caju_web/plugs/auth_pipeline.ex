defmodule Caju.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :caju,
    module: Caju.Guardian,
    error_handler: CajuWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
