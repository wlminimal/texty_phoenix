defmodule TextingWeb.Dashboard.Admin.CustomerView do
  use TextingWeb, :view
  alias Texting.Formatter
  import Scrivener.HTML

  def display_datetime(datetime) do
    Formatter.display_date_time(datetime)
  end

  def display_phone_number(phone_number) do
    Formatter.display_phone_number(phone_number)
  end

  def display_fullname(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def unit_time_to_normal_time(datetime) do
    Formatter.unix_time_to_normal_time(datetime) |> display_datetime()
  end

  def display_stripe_money(amount) do
    Formatter.stripe_money_to_currency(amount)
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
