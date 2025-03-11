defmodule Cartao.Services.MccsServiceTest do
  use Cartao.DataCase
  alias Cartao.Services.MccsService
  alias Cartao.Mccs
  alias Cartao.Repo

  setup do
    # Limpar a tabela antes de cada teste
    Repo.delete_all(Mccs)
    :ok
  end

  describe "buscar_mccs/2" do
    test "retorna MCC quando encontrado pelo código" do
      mcc_attrs = %{
        codigo_mcc: "5411",
        nome_estabelecimento: "Supermercado A",
        permite_food: true,
        permite_meal: false,
        permite_cash: false
      }

      {:ok, _mcc} = Repo.insert(%Mccs{} |> Mccs.changeset(mcc_attrs))

      {:ok, mcc_encontrado} = MccsService.buscar_mccs("5411", "Qualquer Nome")
      assert mcc_encontrado.codigo_mcc == "5411"
    end

    test "retorna MCC quando encontrado pelo nome do estabelecimento" do
      mcc_attrs = %{
        codigo_mcc: "5811",
        nome_estabelecimento: "Restaurante A",
        permite_food: false,
        permite_meal: true,
        permite_cash: false
      }

      {:ok, _mcc} = Repo.insert(%Mccs{} |> Mccs.changeset(mcc_attrs))

      {:ok, mcc_encontrado} = MccsService.buscar_mccs("qualquer_codigo", "Restaurante")
      assert mcc_encontrado.nome_estabelecimento == "Restaurante A"
    end

    test "retorna erro quando MCC não encontrado" do
      result = MccsService.buscar_mccs("codigo_inexistente", "estabelecimento_inexistente")
      assert result == {:error, :mcc_nao_encontrado}
    end
  end

  describe "buscar_mccs_por_tipo/1" do
    test "retorna MCCs pelo tipo de benefício" do
      {:ok, _} =
        Repo.insert(
          %Mccs{}
          |> Mccs.changeset(%{
            codigo_mcc: "5411",
            nome_estabelecimento: "Supermercado A",
            permite_food: true
          })
        )

      {:ok, _} =
        Repo.insert(
          %Mccs{}
          |> Mccs.changeset(%{
            codigo_mcc: "5412",
            nome_estabelecimento: "Supermercado B",
            permite_food: true
          })
        )

      {:ok, _} =
        Repo.insert(
          %Mccs{}
          |> Mccs.changeset(%{
            codigo_mcc: "5811",
            nome_estabelecimento: "Restaurante A",
            permite_food: false,
            permite_meal: false,
            permite_cash: true
          })
        )

      {:ok, mccs_food} = MccsService.buscar_mccs_por_tipo(:food)
      assert length(mccs_food) == 2
      assert Enum.all?(mccs_food, fn m -> m.permite_food end)

      result = MccsService.buscar_mccs_por_tipo(:meal)
      assert result == {:error, :nenhum_mcc_encontrado}
    end
  end
end
