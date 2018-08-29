defmodule TextingWeb.Dashboard.InvoiceView do
  use TextingWeb, :view
  alias Texting.Formatter
  import Scrivener.HTML

  def display_datetime(datetime) do
    Formatter.display_date_time(datetime)
  end

  @spec display_stripe_money(any()) :: none()
  def display_stripe_money(amount) do
    Formatter.stripe_money_to_currency(amount)
  end

  @spec unit_time_to_normal_time(non_neg_integer()) :: binary()
  def unit_time_to_normal_time(datetime) do
    Formatter.unix_time_to_normal_time(datetime) |> display_datetime()
  end
end
