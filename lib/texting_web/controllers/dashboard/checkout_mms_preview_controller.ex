defmodule TextingWeb.Dashboard.CheckoutMmsPreviewController do
  use TextingWeb, :controller
  alias Texting.Account
  alias Texting.Credit
  alias Texting.Sales
  alias Texting.Mms
  alias Texting.Messenger
  alias Texting.Helpers
  alias Texting.Bitly

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
              credit_used: recipients.total,
              user: user,
              upload_image_url: recipients.media_url,
              name: recipients.name,
              description: recipients.description
            )

          user.credits - credit_used < 0 ->
            conn
            |> put_flash(:info, "You need a more credit!")
            |> render("index.html",
              recipients: recipients,
              message: recipients.message,
              credit_used: recipients.total,
              user: user,
              upload_image_url: recipients.media_url,
              name: recipients.name,
              description: recipients.description
            )
        end
    end
  end

  def send_mms(conn, _params) do
    recipients = conn.assigns.recipients
    %{line_items: line_items} = recipients
    # 1. Make phone number list from line_items
    phone_numbers = Enum.map(line_items, fn r -> r.phone_number end)
    # 2. Deduct from remaining credits
    user = conn.assigns.current_user
    changeset = Account.change_user(user)
    credit_used = Decimal.to_integer(recipients.total)
    # Check if user has enought credit, if not redirect to buy credit page
    case Credit.substract_credit(changeset, credit_used) do
      {:ok, changeset} ->
        Account.update_user(changeset)

        # Send sms witn new spauwned process
        spawn(fn -> send_message_and_save(user, recipients, phone_numbers) end)

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

  def send_message_and_save(user, recipients, phone_numbers) do
    Process.sleep(5000)
    msg_sid = user.twilio.msid
    account = user.twilio.account
    token = user.twilio.token
    status_callback = System.get_env("MESSAGE_STATUS_CALLBACK")
    media_url_exp = Helpers.add_days_to_current_time(5)
    attrs = %{"message_type" => "mms", "media_url_exp" => media_url_exp}
    # Send message
    results =
      Mms.send_mms_with_messaging_service_async(
        phone_numbers,
        recipients.message,
        msg_sid,
        recipients.media_url,
        status_callback,
        account,
        token
      )

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
