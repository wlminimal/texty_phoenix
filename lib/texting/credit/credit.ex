defmodule Texting.Credit do
  alias Ecto.Changeset

  #@unit_price 5 # 0.05
  # @unit_price_tier_2 4.5
  # @unit_price_tier_3 4
  # @unit_price_tier_4 3.5
  # @unit_price_tier_5 3
  # @unit_price_tier_6 2.5
  # @unit_price_tier_7 2

  def add_credit(changeset, amount) do
    remaining_credit = Changeset.get_field(changeset, :credits, 0)
    adding_credit = calculate_credit(amount)
    new_credit = remaining_credit + adding_credit
    changeset =  Changeset.put_change(changeset, :credits, new_credit)
    IO.puts "+++++++++++++++++++++++++++++++++++++++"
    IO.inspect changeset
    IO.puts "+++++++++++++++++++++++++++++++++++++++"
    changeset
  end

  @doc """
  Give Free credits when register
  """
  def give_free_credit(changeset, amount) do
    changeset = changeset
      |>Changeset.put_change(:credits, amount)
    changeset
  end

  @doc """
  params "changeset" is user's changeset
  """
  def substract_credit(changeset, credit_used) do
    remaining_credit = Changeset.get_field(changeset, :credits, 0 )
    new_credit = remaining_credit - credit_used

    if new_credit >= 0 do
      changeset = Changeset.put_change(changeset, :credits, new_credit)
      {:ok, changeset}
    else
      {:error, "You don't have an enough credits. You need #{new_credit} more credits"}
    end
  end

  def calculate_credit(amount) when is_integer(amount) or is_float(amount) do
    unit_price = System.get_env("SMS_PRICE")
    {unit_price, _} = Integer.parse unit_price

    add_extra_credit(amount, unit_price)
  end

  def calculate_credit(amount) when is_binary(amount) do
    {amount, _} = Integer.parse(amount)
    unit_price = System.get_env("SMS_PRICE")
    {unit_price, _} = Integer.parse unit_price
    add_extra_credit(amount, unit_price)
  end

  def add_extra_credit(amount, unit_price) do
    cond do
      # for free credit when sign up
      amount == 3500 ->
        div(amount, unit_price) # for free credit when sign up
      amount == 5500 ->
        div(amount, unit_price) + 50
      amount == 9500 ->
        div(amount, unit_price) + 100
      amount == 13500 ->
        div(amount, unit_price) + 200
      amount == 18500 ->
        div(amount, unit_price) + 300
      amount == 22500 ->
        div(amount, unit_price) + 500
    end
  end

  # def add_extra_amount(changeset, amount, plan_name) do
  #   cond do
  #     plan_name == "Bronze" ->
  #       new_amount = amount + 0
  #       changeset |> add_credit(new_amount)
  #     plan_name == "Silver" ->
  #       new_amount = amount + 500 # $5.00
  #       changeset |> add_credit(new_amount)
  #     plan_name == "Gold" ->
  #       new_amount = amount + 1500 # extra $15.00
  #       changeset |> add_credit(new_amount)
  #     plan_name == "Platinum" ->
  #       new_amount = amount + 4500 # extra $45.00
  #       changeset |> add_credit(new_amount)
  #     plan_name == "Diamond" ->
  #       new_amount = amount + 10000 # extran $100.00
  #       IO.puts "++++++++++amount+++++++++++"
  #       IO.inspect amount
  #       IO.inspect new_amount
  #       IO.puts "+++++++++++++++++++++++++++"
  #       changeset |> add_credit(new_amount)

  #     plan_name == "Master" ->
  #       new_amount = amount + 20000 # extra $200
  #       changeset |> add_credit(new_amount)
  #     plan_name == "GrandMaster" ->
  #       new_amount = amount + 60000 # extra $600
  #       changeset |> add_credit(new_amount)
  #     true ->
  #       IO.puts "Error!"
  #   end
  # end

end
