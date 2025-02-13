defmodule Caju.Guardian do
  use Guardian, otp_app: :caju
  alias Caju.Services.EstabelecimentosService

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.uuid)}
  end

  def resource_from_claims(%{"sub" => uuid}) do
    case EstabelecimentosService.get_estabelecimento_uuid(uuid) do
      nil -> {:error, :resource_not_found}
      estabelecimento -> {:ok, estabelecimento}
    end
  end
end
