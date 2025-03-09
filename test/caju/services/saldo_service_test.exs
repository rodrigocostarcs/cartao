defmodule Caju.Services.SaldoServiceTest do
  use Caju.DataCase
  alias Caju.Services.SaldoService
  alias Caju.{Contas, Carteiras, ContasCarteiras, Repo}

  setup do
    # Limpar dados existentes
    Repo.delete_all(ContasCarteiras)
    Repo.delete_all(Carteiras)
    Repo.delete_all(Contas)

    # Criar conta de teste
    {:ok, conta} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "555555",
        nome_titular: "Teste de Saldo"
      })
      |> Repo.insert()

    # Criar carteiras
    {:ok, food_carteira} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :food,
        descricao: "Carteira Alimentação Teste"
      })
      |> Repo.insert()

    {:ok, meal_carteira} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :meal,
        descricao: "Carteira Refeição Teste"
      })
      |> Repo.insert()

    # Associar carteiras à conta
    {:ok, conta_carteira_food} =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: food_carteira.id,
        saldo: Decimal.new("2000.00"),
        saldo_reservado: Decimal.new("500.00"),
        ativo: true
      })
      |> Repo.insert()

    {:ok, conta_carteira_meal} =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: meal_carteira.id,
        saldo: Decimal.new("1000.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true
      })
      |> Repo.insert()

    {:ok,
     conta: conta,
     food_carteira: food_carteira,
     meal_carteira: meal_carteira,
     conta_carteira_food: conta_carteira_food,
     conta_carteira_meal: conta_carteira_meal}
  end

  describe "consultar_saldo/2" do
    test "retorna saldo correto para carteira food", %{conta: conta} do
      {:ok, saldo_info} = SaldoService.consultar_saldo(conta.numero_conta, "food")

      assert saldo_info[:conta_numero] == conta.numero_conta
      assert saldo_info[:titular] == conta.nome_titular
      assert saldo_info[:tipo_carteira] == "food"
      assert saldo_info[:saldo] == 2000.0
      assert saldo_info[:saldo_reservado] == 500.0
      assert saldo_info[:saldo_disponivel] == 1500.0
    end

    test "retorna saldo correto para carteira meal", %{conta: conta} do
      {:ok, saldo_info} = SaldoService.consultar_saldo(conta.numero_conta, "meal")

      assert saldo_info[:conta_numero] == conta.numero_conta
      assert saldo_info[:titular] == conta.nome_titular
      assert saldo_info[:tipo_carteira] == "meal"
      assert saldo_info[:saldo] == 1000.0
      assert saldo_info[:saldo_reservado] == 0.0
      assert saldo_info[:saldo_disponivel] == 1000.0
    end

    test "retorna erro para conta inexistente" do
      result = SaldoService.consultar_saldo("999999", "food")
      assert result == {:error, :conta_nao_encontrada}
    end

    test "retorna erro para carteira inexistente", %{conta: conta} do
      result = SaldoService.consultar_saldo(conta.numero_conta, "cash")
      assert result == {:error, :carteira_nao_encontrada}
    end

    test "retorna erro para tipo de carteira inválido", %{conta: conta} do
      result = SaldoService.consultar_saldo(conta.numero_conta, "invalid_type")
      assert result == {:error, :tipo_carteira_invalido}
    end
  end
end
