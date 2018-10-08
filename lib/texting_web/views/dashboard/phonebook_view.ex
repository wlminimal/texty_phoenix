defmodule TextingWeb.Dashboard.PhonebookView do
  use TextingWeb, :view
  import Scrivener.HTML
  import TextingWeb.Dashboard.PersonView, only: [display_phone_number: 1]
  alias Texting.Contact
  alias Texting.PaginationHelpers

  def phonebook_total(phonebook_id) do
    people = Contact.get_people(phonebook_id)
    Enum.count(people)
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
