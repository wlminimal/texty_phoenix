defmodule TextingWeb.Dashboard.CheckoutMmsPreviewView do
  use TextingWeb, :view
  def show_buy_credit_button(current_credit, request_credit) do
    request_credit = Decimal.to_integer(request_credit)
    cond do
      current_credit - request_credit >= 0 ->
        false
      current_credit - request_credit < 0 ->
        true
    end
  end
end
