defmodule Caju.Services.MccsService do
  alias Caju.Repositories.MccsRepository

  def buscar_mccs(mcc, estabelecimento) do
    case MccsRepository.pegar_mcc_por_codigo(mcc) do
      nil ->
        case MccsRepository.pegar_mcc_estabelecimento(estabelecimento) do
          [] -> {:error, :mcc_nao_encontrado}
          mcc -> valida_quantidade_mccs(mcc)
        end

      mcc ->
        {:ok, mcc}
    end
  end

  defp valida_quantidade_mccs(mccs) do
    if length(mccs) > 1 do
      {:error, :mcc_duplicado}
    else
      {:ok, mccs}
    end
  end
end
