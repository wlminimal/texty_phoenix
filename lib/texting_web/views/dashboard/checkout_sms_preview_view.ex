defmodule TextingWeb.Dashboard.CheckoutSmsPreviewView do
  use TextingWeb, :view
  alias Texting.Formatter

  def show_buy_credit_button(current_credit, request_credit) do
    # {request_credit, _} = Integer.parse request_credit
    cond do
      current_credit - request_credit >= 0 ->
        false
      current_credit - request_credit < 0 ->
        true
    end
  end

  def display_date_with_time(datetime) do
    Formatter.display_date_with_time(datetime)
  end
end


# content_tag :button, [{:data,[to: "/dashboard/buy-credit", method: "get"]}, type: "submit", class: "btn" ] do
#   "Buy Credit"
# end

