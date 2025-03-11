defmodule Cartao.Services.ContasCarteirasServiceTest do
  use Cartao.DataCase
  alias Cartao.Services.ContasCarteirasService
  alias Cartao.{Contas, Carteiras, ContasCarteiras, Mccs, Repo}

  setup do
    # Limpar dados existentes
    Repo.delete_all(ContasCarteiras)
    Repo.delete_all(Mccs)
    Repo.delete_all(Carteiras)
    Repo.delete_all(Contas)

    # Criar dados de teste
    {:ok, conta} =
      %Contas{}
      |> Contas.changeset(%{
        numero_conta: "123456-#{:os.system_time()}",
        nome_titular: "Teste Unitário"
      })
      |> Repo.insert()

    {:ok, food} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :food,
        descricao: "Carteira Alimentação"
      })
      |> Repo.insert()

    {:ok, cash} =
      %Carteiras{}
      |> Carteiras.changeset(%{
        tipo_beneficio: :cash,
        descricao: "Carteira Dinheiro"
      })
      |> Repo.insert()

    {:ok, mcc} =
      %Mccs{}
      |> Mccs.changeset(%{
        codigo_mcc: "5411",
        nome_estabelecimento: "Supermercado Teste",
        permite_food: true,
        permite_meal: false,
        permite_cash: false
      })
      |> Repo.insert()

    conta_carteira_food =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: food.id,
        saldo: Decimal.new("1000.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true
      })
      |> Repo.insert!()

    conta_carteira_cash =
      %ContasCarteiras{}
      |> ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: cash.id,
        saldo: Decimal.new("2000.00"),
        saldo_reservado: Decimal.new("0.00"),
        ativo: true
      })
      |> Repo.insert!()

    conta_carteira_food = Repo.preload(conta_carteira_food, [:conta, :carteira])
    conta_carteira_cash = Repo.preload(conta_carteira_cash, [:conta, :carteira])

    {:ok,
     conta: conta,
     food: food,
     cash: cash,
     conta_carteira_food: conta_carteira_food,
     conta_carteira_cash: conta_carteira_cash,
     mcc: mcc}
  end

  describe "saldo_suficiente?/4" do
    test "retorna true para carteira com saldo e MCC compatível", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash,
      mcc: mcc
    } do
      carteiras = [conta_carteira_food, conta_carteira_cash]

      result =
        ContasCarteirasService.saldo_suficiente?(
          carteiras,
          500.00,
          mcc.codigo_mcc,
          {:ok, mcc}
        )

      assert {:retorno_mcc, true} = result
    end

    test "usa carteira cash como fallback quando MCC não é compatível", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash,
      mcc: mcc
    } do
      mcc_incompativel = %{mcc | permite_food: false}
      carteiras = [conta_carteira_food, conta_carteira_cash]

      result =
        ContasCarteirasService.saldo_suficiente?(
          carteiras,
          500.00,
          mcc.codigo_mcc,
          {:ok, mcc_incompativel}
        )

      assert {:carteira_cash, true} = result
    end

    test "retorna erro quando não há saldo suficiente", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash,
      mcc: mcc
    } do
      carteiras = [conta_carteira_food, conta_carteira_cash]

      result =
        ContasCarteirasService.saldo_suficiente?(
          carteiras,
          5000.00,
          mcc.codigo_mcc,
          {:ok, mcc}
        )

      assert {:error, :saldo_insuficiente} = result
    end

    test "usa carteira cash quando MCC não é encontrado", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash
    } do
      carteiras = [conta_carteira_food, conta_carteira_cash]

      result =
        ContasCarteirasService.saldo_suficiente?(
          carteiras,
          500.00,
          "9999",
          {:error, :mcc_nao_encontrado}
        )

      assert {:carteira_cash, true} = result
    end
  end

  describe "possui_carteira_cash_e_saldo?/2" do
    test "retorna carteira cash quando há saldo suficiente", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash
    } do
      carteiras = [conta_carteira_food, conta_carteira_cash]

      {:ok, carteira} = ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, 1000.00)
      assert carteira.carteira.tipo_beneficio == :cash
    end

    test "retorna erro quando saldo é insuficiente", %{
      conta_carteira_food: conta_carteira_food,
      conta_carteira_cash: conta_carteira_cash
    } do
      carteiras = [conta_carteira_food, conta_carteira_cash]

      result = ContasCarteirasService.possui_carteira_cash_e_saldo?(carteiras, 3000.00)
      assert {:error, :saldo_insuficiente} = result
    end
  end
end
