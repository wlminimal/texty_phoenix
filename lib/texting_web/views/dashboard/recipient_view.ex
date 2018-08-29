defmodule TextingWeb.Dashboard.RecipientView do
  use TextingWeb, :view
  import Scrivener.HTML
  alias Texting.Sales.Order
  import TextingWeb.Dashboard.PersonView, only: [display_phone_number: 1]

  def recipient_count(conn = %Plug.Conn{}) do
    recipient_count(conn.assigns.recipients)
  end

  def recipient_count(recipients = %Order{}) do
    %{line_items: line_items} = recipients
    Enum.count(line_items)
  end

  def recipient_count(page = %Scrivener.Page{}) do
    page.total_entries
  end

  # def recipient_count(recipients_page = %Scrivener.Page{entries: [entries]}) do
  #   IO.inspect recipients_page
  #   %{line_items: line_items} = entries
  #   Enum.count(line_items)
  # end
end
