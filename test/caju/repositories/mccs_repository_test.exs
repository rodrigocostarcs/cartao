defmodule Caju.Repositories.MccsRepositoryTest do
  use Caju.DataCase
  alias Caju.Repositories.MccsRepository
  alias Caju.Mccs
  alias Caju.Repo

  setup do
    # Limpar a tabela de MCCs antes de cada teste para evitar duplicidade
    Repo.delete_all(Mccs)
    :ok
  end

  describe "pegar_mcc_por_codigo/1" do
    test "retorna MCC quando encontrado pelo código" do
      # Criar um MCC para teste
      mcc_attrs = %{
        codigo_mcc: "5411",
        nome_estabelecimento: "Supermercado Teste",
        permite_food: true
      }

      {:ok, mcc} = Repo.insert(Mccs.changeset(%Mccs{}, mcc_attrs))

      # Buscar o MCC pelo código
      result = MccsRepository.pegar_mcc_por_codigo("5411")
      assert result.id == mcc.id
      assert result.codigo_mcc == "5411"
    end

    test "retorna nil quando MCC não encontrado" do
      result = MccsRepository.pegar_mcc_por_codigo("codigo_inexistente")
      assert result == nil
    end
  end

  describe "pegar_mcc_estabelecimento/1" do
    test "retorna MCCs que correspondem ao nome do estabelecimento" do
      # Criar MCCs para teste
      Repo.insert(
        Mccs.changeset(%Mccs{}, %{
          codigo_mcc: "5411",
          nome_estabelecimento: "Supermercado ABC",
          permite_food: true
        })
      )

      Repo.insert(
        Mccs.changeset(%Mccs{}, %{
          codigo_mcc: "5412",
          nome_estabelecimento: "Supermercado XYZ",
          permite_food: true
        })
      )

      # Buscar MCCs pelo nome parcial
      result = MccsRepository.pegar_mcc_estabelecimento("Supermercado")
      assert length(result) == 2

      # Buscar por nome específico
      result = MccsRepository.pegar_mcc_estabelecimento("ABC")
      assert length(result) == 1
      assert hd(result).nome_estabelecimento == "Supermercado ABC"
    end

    test "retorna lista vazia quando nenhum estabelecimento corresponde" do
      result = MccsRepository.pegar_mcc_estabelecimento("Nome Inexistente")
      assert result == []
    end
  end

  describe "pegar_mccs_por_tipo/1" do
    test "retorna MCCs que permitem o tipo de benefício especificado" do
      # Criar MCCs para teste
      Repo.insert(
        Mccs.changeset(%Mccs{}, %{
          codigo_mcc: "5411",
          nome_estabelecimento: "Supermercado Food",
          permite_food: true,
          permite_meal: false,
          permite_cash: false
        })
      )

      Repo.insert(
        Mccs.changeset(%Mccs{}, %{
          codigo_mcc: "5811",
          nome_estabelecimento: "Restaurante Meal",
          permite_food: false,
          permite_meal: true,
          permite_cash: false
        })
      )

      # Buscar MCCs por tipo
      food_mccs = MccsRepository.pegar_mccs_por_tipo(:food)
      assert length(food_mccs) == 1
      assert hd(food_mccs).nome_estabelecimento == "Supermercado Food"

      meal_mccs = MccsRepository.pegar_mccs_por_tipo(:meal)
      assert length(meal_mccs) == 1
      assert hd(meal_mccs).nome_estabelecimento == "Restaurante Meal"
    end

    test "retorna lista vazia quando nenhum MCC permite o tipo especificado" do
      result = MccsRepository.pegar_mccs_por_tipo(:cash)
      assert result == []
    end
  end
end
