defmodule TextingWeb.Plugs.FetchRecipients do
  import Plug.Conn

  alias Texting.Sales
  alias Texting.Sales.Order

  def init(_opts), do: nil

  def call(conn, _) do
    user = conn.assigns.current_user
    with recipients_id <- get_session(conn, :recipients_id),
      true <- is_integer(recipients_id),
      %Order{} = recipients <- Sales.get_recipients_list_status_order(recipients_id, user.id)
    do

      conn |> assign(:recipients, recipients)
    else
      _ ->
        user = conn.assigns.current_user
        recipients = Sales.create_initial_order(user)
        conn
        |> put_session(:recipients_id, recipients.id) # This is an Order id with status "In Recipient List"
        |> assign(:recipients, recipients)
    end
  end
end
