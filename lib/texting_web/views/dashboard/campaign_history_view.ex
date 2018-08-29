defmodule TextingWeb.Dashboard.CampaignHistoryView do
  use TextingWeb, :view
  alias Texting.Formatter
  import Scrivener.HTML

  def display_datetime(datetime) do
    Formatter.display_date_time(datetime)
  end

  def display_phone_number(phone_number) do
    Formatter.display_phone_number(phone_number)
  end
end
