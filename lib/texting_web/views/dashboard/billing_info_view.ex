defmodule TextingWeb.Dashboard.BillingInfoView do
  use TextingWeb, :view
  alias Texting.Formatter

  def display_money(money) do
    money = Formatter.stripe_money_to_currency(money)
    money
  end

  def display_paid_time(time) do
    Formatter.unix_time_to_normal_time(time)
  end

  def display_card_logo(card_brand) do
    cond do
      card_brand == "Visa" ->
        raw("<img src='/images/visa.png' alt='Visa' class='card-icon'")
      card_brand == "Master" ->
        raw("<img src='/images/mastercard.png' alt='Master' class='card-icon'")
      card_brand == "American Express" ->
        raw("<img src='/images/amex.png' alt='Amex' class='card-icon'")
      true ->
        raw("<i class='material-icons'>credit_card</i>")
    end
  end
end
