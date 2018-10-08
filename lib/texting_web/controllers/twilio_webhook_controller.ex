defmodule TextingWeb.TwilioWebhookController do
  use TextingWeb, :controller
  alias Texting.{Account, Contact}
  alias Texting.Repo
  alias Texting.Messenger
  alias Texting.Formatter
  alias Texting.Sms

  @stop_message ["stop", "no", "unsubscribe"]
  @subscribe_message ["start", "yes", "subscribe"]
  @doc """
  Handle subscribe and unsubscribe.
  If a customer text "stop, no", unsubscribe..
  If a customer text "KEYWORD MESSAGE", subscribe...
  """
  def message_incoming(conn, params) do
    IO.inspect params
    free_account_sid = System.get_env("TWILIO_FREE_ACCOUNT_SID")
    %{"AccountSid" => account_sid, "Body" => message, "From" => from_number} = params
    # Get user by account sid...
    if free_account_sid == account_sid do
      # Do nothing
      conn
      |> put_resp_content_type("text/xml")
      |> send_resp(200, "")
    else
      message = String.downcase(message)
      Enum.each(@stop_message, fn m ->
        case String.contains?(message, m) do
          true ->
            user = Account.get_user_by_twilio(account_sid)
            from_number = String.slice(from_number, 1, 11)

            # There will be multiple contacts spread over phonebook, so get them all
            people = Contact.get_people_by_phonenumber(user.id, from_number)
            unsubscribed_phonebook = Contact.get_or_create_unsubscribed_contact(user)
            people
            |> Enum.each(fn p ->
              changeset = Contact.change_person(p)
              changeset
              |> Ecto.Changeset.put_change(:subscribed, false)
              |> Ecto.Changeset.put_change(:phonebook_id, unsubscribed_phonebook.id)
              |> Repo.update()
            end)
            #TODO: Substract 1 credit for each recipients respond.


          _ ->
            :ok
        end
      end)

      Enum.each(@subscribe_message, fn m ->
        case String.contains?(message, m) do
          true ->
            user = Account.get_user_by_twilio(account_sid)
            from_number = String.slice(from_number, 1, 11)

            people = Contact.get_people_by_phonenumber(user.id, from_number)
            if Enum.empty?(people) do
              # Get Subscriber phonebook
              subscriber_phonebook = Contact.get_or_create_subscribed_contact(user)
              # create a contact(person)
              from_number = from_number |> Formatter.display_phone_number
              attrs = %{"phone_number" => from_number, "name" => ""}
              Contact.create_person(subscriber_phonebook, user, attrs)

              # Send welcome message
              # welcome_message = Account.get_welcome_message_by_user_id(user)
             # status_callback = System.get_env("MESSAGE_STATUS_CALLBACK")
              Sms.send_sms_with_messaging_service_async([from_number],
                user.welcome_message.message,
                user.twilio.msid,
                "",
                user.twilio.account,
                user.twilio.token)
            else
              people
              |> Enum.each(fn p ->
                changeset = Contact.change_person(p)
                changeset
                |> Ecto.Changeset.put_change(:subscribed, true)
                |> Ecto.Changeset.put_change(:phonebook_id, p.previous_phonebook_id)
                |> Repo.update()

              end)

              Sms.send_sms_with_messaging_service_async([from_number],
                user.welcome_message.message,
                user.twilio.msid,
                "",
                user.twilio.account,
                user.twilio.token)
            end


          _ ->
            :ok
        end
      end)

      conn
      |> put_resp_content_type("text/xml")
      |> send_resp(200, "")
    end
  end

  def message_status(conn, %{"MessageStatus" => status} = params) when status in ["undelivered", "failed"] do
    IO.puts "+++++++++++++++++++++++++++++"
    IO.inspect params
    IO.puts "+++++++++++++++++++++++++++++++++++++++++++"
    %{"AccountSid" => _account_sid,
      "From" => from,
      "MessageSid" => message_sid,
      "MessageStatus" => status,
      "SmsSid" => _sms_sid,
      } = params
    message_status_struct = Messenger.get_message_status_by_message_sid(message_sid)
    Messenger.update_message_status(message_status_struct, %{from: Formatter.remove_plus_sign_from_phonenumber(from), status: status})
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, "")
  end

  def message_status(conn, %{"MessageStatus" => status} = params) when status in ["delivered", "sent", "queued", "receiving", "received", "accepted", "sending" ] do

    IO.puts "+++++++++++++++Message Status++++++++++++++"
    IO.inspect params
    IO.puts "+++++++++++++++++++++++++++++++++++++++++++"
    # TODO: Find better solution for this message status update.
    # Twilio Status Callback is not working properly sometime.
    # Even though that message is delivered, status is not updated to "Delivered"
    # So I just marked delivered for this message status

    %{"AccountSid" => _account_sid,
      "From" => from,
      "MessageSid" => message_sid,
      "MessageStatus" => status,
      "SmsSid" => _sms_sid,
      } = params
    message_status_struct = Messenger.get_message_status_by_message_sid(message_sid)
    Messenger.update_message_status(message_status_struct, %{from: Formatter.remove_plus_sign_from_phonenumber(from), status: "delivered"})
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, "")
  end
end
