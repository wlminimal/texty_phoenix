defmodule TextingWeb.Dashboard.AccountInfoView do
  use TextingWeb, :view
  alias Texting.Formatter

  def display_phone_number(phonenumber) do
    Formatter.display_phone_number(phonenumber)
  end

  def display_fullname(user) do
    "#{user.first_name} #{user.last_name}"
  end
end
