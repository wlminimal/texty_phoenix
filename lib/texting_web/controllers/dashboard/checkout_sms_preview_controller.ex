defmodule TextingWeb.Dashboard.CheckoutSmsPreviewController do
  use TextingWeb, :controller
  alias Texting.{Account, Sales, Sms, Credit, Messenger, Bitly}

  def index(conn, _param) do
    recipients = conn.assigns.recipients
    user = conn.assigns.current_user

    case recipients.counts == 0 do
      true ->
        conn
        |> put_flash(:info, "Your recipients list is empty. Add recipients first!")
        |> redirect(to: phonebook_path(conn, :index))

      false ->
        credit_used = Decimal.to_integer(recipients.total)

        cond do
          user.credits - credit_used >= 0 ->
            render(conn, "index.html",
              recipients: recipients,
              message: recipients.message,
              credit_used: credit_used,
              user: user,
              name: recipients.name,
              description: recipients.description
            )

          user.credits - credit_used < 0 ->
            conn
            |> put_flash(:info, "You need a more credit!")
            |> render("index.html",
              recipients: recipients,
              message: recipients.message,
              credit_used: credit_used,
              user: user,
              name: recipients.name,
              description: recipients.description
            )
        end
    end
  end

  def send_sms(conn, _params) do
    recipients = conn.assigns.recipients
    # Deduct from remaining credits
    user = conn.assigns.current_user
    changeset = Account.change_user(user)
    credit_used = Decimal.to_integer(recipients.total)
    # Check if user has enought credit, if not redirect to buy credit page
    case Credit.substract_credit(changeset, credit_used) do
      {:ok, changeset} ->
        Account.update_user(changeset)

        # Spawn new process for sending message and saving to database
        spawn(fn -> send_message_and_save(user, recipients) end)

        conn
        |> put_flash(
          :info,
          "We are sending messages. Your analytics data will be updated shortly."
        )
        |> redirect(to: dashboard_path(conn, :new))

      {:error, message} ->
        conn
        |> put_session(:intending_to_visit, conn.request_path)
        |> put_flash(:info, message)
        |> redirect(to: buy_credit_path(conn, :index))
    end
  end

  def send_message_and_save(user, recipients) do
    msg_sid = user.twilio.msid
    account = user.twilio.account
    token = user.twilio.token
    %{line_items: line_items} = recipients
    #  Make phone number list from line_items
    phone_numbers = Enum.map(line_items, fn r -> r.phone_number end)
    status_callback = System.get_env("MESSAGE_STATUS_CALLBACK")
    attrs = %{"message_type" => "sms"}
    # Send message
    IO.puts("++++++++++++ Start send message +++++++++++++++")
    t0 = :os.system_time(:milli_seconds)

    results =
      Sms.send_sms_with_messaging_service_async(
        phone_numbers,
        recipients.message,
        msg_sid,
        status_callback,
        account,
        token
      )

    IO.puts("++++++++++++ Finish send message +++++++++++++++")
    IO.puts("It took #{:os.system_time(:milli_seconds) - t0} ms")

    IO.puts("++++++++++= Results +++++++++++++++=")
    IO.inspect(results)

    case Sales.confirm_order(recipients, attrs) do
      {:ok, %{id: order_id, user_id: user_id}} ->
        Messenger.create_message_status(results, order_id, user_id)

        # Update Bitly status as Saved
        if is_nil(recipients.bitly_id) do
        else
          bitly = Texting.Bitly.get_bitly_by_id(recipients.bitly_id)
          Bitly.confirm_changeset(bitly) |> Bitly.update()
        end

        {:ok, "We are sending messages. Your analytics data will be updated shortly."}

      {:error, _changeset} ->
        {:error, "Can't send message!"}
    end
  end
end
