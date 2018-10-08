defmodule TextingWeb.Dashboard.CampaignHistoryView do
  use TextingWeb, :view
  alias Texting.Formatter
  import Scrivener.HTML
  alias Texting.PaginationHelpers

  def display_datetime(datetime) do
    Formatter.display_date_time(datetime)
  end

  def display_phone_number(phone_number) do
    Formatter.display_phone_number(phone_number)
  end

  def pagination_for_search_result(conn, page) do
    # below take the params from the conn, leave out the page parameter
    opts =
      conn.query_params
      |> Enum.reject(fn {k, _v} -> k == "page" end)
      |> PaginationHelpers.to_list()
      |> List.flatten()

    Scrivener.HTML.pagination_links(page, opts)
  end
end
