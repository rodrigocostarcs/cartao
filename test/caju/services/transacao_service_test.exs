defmodule Caju.Services.TransacaoServiceTest do
  use Caju.DataCase
  alias Caju.Services.TransacaoService
  alias Caju.{Repo}

  setup do
    # Limpar registros existentes de MCC antes de inserir novos
    Repo.delete_all(Caju.Mccs)

    # 1. Criar conta
    {:ok, conta} =
      Repo.insert(%Caju.Contas{
        numero_conta: "123456",
        nome_titular: "Teste Unitário"
      })

    # 2. Criar carteiras
    {:ok, food} =
      Repo.insert(%Caju.Carteiras{
        tipo_beneficio: :food,
        descricao: "Carteira Alimentação"
      })

    {:ok, meal} =
      Repo.insert(%Caju.Carteiras{
        tipo_beneficio: :meal,
        descricao: "Carteira Refeição"
      })

    {:ok, cash} =
      Repo.insert(%Caju.Carteiras{
        tipo_beneficio: :cash,
        descricao: "Carteira Dinheiro"
      })

    # 3. Associar conta a carteiras com saldo
    _cc_food =
      %Caju.ContasCarteiras{}
      |> Caju.ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: food.id,
        saldo: Decimal.new("1000.00"),
        ativo: true
      })
      |> Repo.insert!()
      |> Repo.preload(:carteira)

    _cc_meal =
      %Caju.ContasCarteiras{}
      |> Caju.ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: meal.id,
        saldo: Decimal.new("2000.00"),
        ativo: true
      })
      |> Repo.insert!()
      |> Repo.preload(:carteira)

    _cc_cash =
      %Caju.ContasCarteiras{}
      |> Caju.ContasCarteiras.changeset(%{
        conta_id: conta.id,
        carteira_id: cash.id,
        saldo: Decimal.new("3000.00"),
        ativo: true
      })
      |> Repo.insert!()
      |> Repo.preload(:carteira)

    # 4. Criar MCCs utilizando changeset para evitar duplicação
    {:ok, _} =
      %Caju.Mccs{}
      |> Caju.Mccs.changeset(%{
        codigo_mcc: "5411",
        nome_estabelecimento: "Supermercado Teste",
        permite_food: true,
        permite_meal: false,
        permite_cash: false
      })
      |> Repo.insert()

    {:ok, _} =
      %Caju.Mccs{}
      |> Caju.Mccs.changeset(%{
        codigo_mcc: "5811",
        nome_estabelecimento: "Restaurante Teste",
        permite_food: false,
        permite_meal: true,
        permite_cash: false
      })
      |> Repo.insert()

    {:ok, conta: conta, food: food, meal: meal, cash: cash}
  end

  describe "buscar_carteira_por_conta/1" do
    test "retorna carteiras associadas a uma conta existente", %{conta: conta} do
      {:ok, carteiras} = TransacaoService.buscar_carteira_por_conta(conta.numero_conta)
      assert length(carteiras) == 3
    end

    test "retorna erro para conta inexistente" do
      result = TransacaoService.buscar_carteira_por_conta("99999999")
      assert result == {:error, :conta_nao_encontrada}
    end
  end

  describe "efetivar_transacao/4" do
    test "realiza transação com MCC alimentação", %{conta: conta} do
      {:ok, carteiras} = TransacaoService.buscar_carteira_por_conta(conta.numero_conta)

      result =
        TransacaoService.efetivar_transacao(carteiras, 100.00, "5411", "Supermercado Teste")

      assert {:ok, {:ok, "00"}} = result
    end

    test "realiza transação com MCC refeição", %{conta: conta} do
      {:ok, carteiras} = TransacaoService.buscar_carteira_por_conta(conta.numero_conta)

      result = TransacaoService.efetivar_transacao(carteiras, 100.00, "5811", "Restaurante Teste")

      assert {:ok, {:ok, "00"}} = result
    end

    test "retorna erro para transação com saldo insuficiente", %{conta: conta} do
      {:ok, carteiras} = TransacaoService.buscar_carteira_por_conta(conta.numero_conta)

      result =
        TransacaoService.efetivar_transacao(carteiras, 5000.00, "5411", "Supermercado Teste")

      assert {:error, :saldo_insuficiente} = result
    end

    test "usa carteira cash para MCC não encontrado", %{conta: conta} do
      {:ok, carteiras} = TransacaoService.buscar_carteira_por_conta(conta.numero_conta)

      result = TransacaoService.efetivar_transacao(carteiras, 100.00, "9999", "Loja Inexistente")

      assert {:ok, {:ok, "00"}} = result
    end
  end
end
