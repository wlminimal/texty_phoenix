defmodule TextingWeb.Dashboard.CheckoutSmsPreviewController do
  use TextingWeb, :controller
  alias Texting.Account
  alias Texting.Sales
  alias Texting.Sms
  alias Texting.Credit
  alias Texting.Messenger
  alias Texting.Bitly


  def index(conn, _param) do
    recipients = conn.assigns.recipients
    user = conn.assigns.current_user
    bitlink_id = get_session(conn, :bitly_id)
    IO.puts "++++++++++++++ Bitlink ID +++++++++++++++++"
    IO.inspect bitlink_id
    case recipients.counts == 0 do
      true ->
        conn
        |> put_flash(:info, "Your recipients list is empty. Add recipients first!")
        |> redirect(to: phonebook_path(conn, :index))

      false ->
        credit_used = Decimal.to_integer(recipients.total)
        cond do
          user.credits - credit_used >= 0 ->
            render conn, "index.html", recipients: recipients,
                                      message: recipients.message,
                                      credit_used: credit_used,
                                      user: user,
                                      name: recipients.name,
                                      description: recipients.description
          user.credits - credit_used < 0 ->
            conn
            |> put_flash(:info, "You need a more credit!")
            |> render("index.html", recipients: recipients,
                                    message: recipients.message,
                                    credit_used: credit_used,
                                    user: user,
                                    name: recipients.name,
                                    description: recipients.description)
        end
    end
  end

  def send_sms(conn, _params) do
    recipients = conn.assigns.recipients
    %{line_items: line_items} = recipients
    # 1. Make phone number list from line_items
    phone_numbers = Enum.map(line_items, fn r -> r.phone_number end)
    IO.puts "+++++++++++++++SMS conn++++++++++++++++++++++"
    IO.inspect conn
    IO.puts "++++++++++++++++conn++++++++++++++++++++++"


     # 2. Deduct from remaining credits
     user = conn.assigns.current_user
     msg_sid = user.twilio.msid
     account = user.twilio.account
     token = user.twilio.token
     changeset = Account.change_user(user)

     credit_used = Decimal.to_integer(recipients.total)

     status_callback = System.get_env("MESSAGE_STATUS_CALLBACK")
     # Check if user has enought credit, if not redirect to buy credit page
     case Credit.substract_credit(changeset, credit_used) do
       {:ok, changeset} ->
         Account.update_user(changeset)
         # Send sms
         results = Sms.send_sms_with_messaging_service_async(phone_numbers, recipients.message, msg_sid, status_callback, account, token)

         attrs = %{"message_type" => "sms"}
         case Sales.confirm_order(recipients, attrs) do
          {:ok, %{id: order_id, user_id: user_id}} ->
            Messenger.create_message_status(results, order_id, user_id)
            # Update Bitly status as Saved
            bitly_id = get_session(conn, :bitly_id)
            if bitly_id !== "" do
              IO.puts "++++++++++BITLY_ID+++++++++++++++++++++++"
              IO.inspect bitly_id
              IO.puts "+++++++++++++++++++++++++++++++++"

              bitly = Bitly.get_bitly_by_id(bitly_id)
              Bitly.confirm_changeset(bitly) |> Bitly.update()
            end
            conn
            |> put_flash(:info, "Message sent successfully. Your analytics data will be updated shortly.")
            |> redirect(to: dashboard_path(conn, :new))
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Can't send message!")
            |> redirect(to: checkout_mms_preview_path(conn, :index))
         end

       {:error, message} ->
         conn
         |> put_session(:intending_to_visit, conn.request_path)
         |> put_flash(:info, message)
         |> redirect(to: buy_credit_path(conn, :new))
     end
  end

end
