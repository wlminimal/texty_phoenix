defmodule TextingWeb.CodeVerifyCommander do
  use Drab.Commander
  alias Texting.PhoneVerify

  defhandler send_verify_code(socket, sender) do
    phonenumber = sender.params["phone_number"]
    case PhoneVerify.phone_verify_start(phonenumber) do
      {:ok, _message} ->
        set_prop socket, "#phone-verify-message", innerHTML: "Sent code successfully!"
      {:error, reason} ->
        set_prop socket, "#phone-verify-message", innerHTML: "Something went wrong. Please try again."
    end
  end
end
