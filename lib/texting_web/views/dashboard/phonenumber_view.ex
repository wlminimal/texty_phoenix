defmodule TextingWeb.Dashboard.PhonenumberView do
  use TextingWeb, :view
  alias Texting.Messenger

  def can_buy_phone_number?(user) do
    available_phonenumber_count = user.twilio.available_phone_number_count
    current_phonenumber_count = Enum.count(Messenger.get_phonenumbers(user))
    cond do
      available_phonenumber_count >= current_phonenumber_count ->
        true
      available_phonenumber_count <= current_phonenumber_count ->
        false
    end
  end

  def current_phonenumber_count(user) do
    Enum.count(Messenger.get_phonenumbers(user))
  end

end
