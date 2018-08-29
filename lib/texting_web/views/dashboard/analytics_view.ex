defmodule TextingWeb.Dashboard.AnalyticsView do
  use TextingWeb, :view
  import Scrivener.HTML

  alias Texting.Formatter

  def display_date(date) do
    Formatter.display_date_time(date)
  end
end
