defmodule TextingWeb.Dashboard.PersonView do
  use TextingWeb, :view
  alias Texting.Formatter
  @doc """
  Convert phone number from 1 213 333 4444
  to (213)333-4444 for display purpose
  """
  @spec display_phone_number(String.t) :: String.t
  def display_phone_number(phone_number) do
    Formatter.display_phone_number(phone_number)
  end
end
