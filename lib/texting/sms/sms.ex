defmodule Texting.Sms do
  alias Messageman

  def send_sms_with_messaging_service_async(phone_numbers, message, msg_sid, status_callback, account, token) do
    Messageman.send_sms_with_messaging_service_async(phone_numbers, message, msg_sid, status_callback, account, token)
  end
end
