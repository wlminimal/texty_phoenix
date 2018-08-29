defmodule TextingWeb.Dashboard.CheckoutSmsController do
  use TextingWeb, :controller
  alias Texting.Sales

  def show_sms(conn, _params) do
    recipients = conn.assigns.recipients

    case recipients.counts == 0 do
      true ->
        conn
        |> put_flash(:info, "Your recipients list is empty. Add recipients first!")
        |> redirect(to: phonebook_path(conn, :index))

      false ->
        recipients_changeset = Sales.change_recipients(recipients)
        user = conn.assigns.current_user
        render conn, "send_sms.html",
                      recipients: recipients,
                      recipients_changeset: recipients_changeset,
                      user: user,
                      long_url: "",
                      shorten_url: "",
                      bitlink_id: ""
    end
  end

  @doc """
  get information and put_session and redirect to checkout preview page
  """
  def preview_sms(conn, %{"sms" => %{"message" => message, "total_credit" => credit_used, "name" => name, "description" => description, "bitlink_id" => bitly_id}}) do
    recipients = conn.assigns.recipients
    attrs = %{
      "message" => message,
      "total" => credit_used,
      "name" => name,
      "description" => description
    }
    order = Sales.update_recipients(recipients, attrs)
    conn = assign(conn, :recipients, order)
    IO.puts "++++++++++BITLY_ID+++++++++++++++++++++++"
    IO.inspect bitly_id
    IO.puts "+++++++++++++++++++++++++++++++++"
    conn
    |> put_session(:bitly_id, bitly_id )
    |> redirect(to: checkout_sms_preview_path(conn, :index))
   end
end
