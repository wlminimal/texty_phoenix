defmodule Texting.Mms do
  alias Messageman

  def send_mms_with_messaging_service_async(phone_numbers, message, msg_sid, media_url, status_callback, account, token) do
    Messageman.send_mms_with_messaging_service_async(phone_numbers, message, msg_sid, media_url, status_callback, account, token)
  end
end
