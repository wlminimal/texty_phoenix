defmodule Texting.Contact.SearchContact do
  import Ecto.Query, warn: false
  alias Texting.Repo
  alias Texting.Contact.Person
  alias Texting.Search

  def get_search_results(conn, params, phonebook_id) do
    query = from p in Person, where: p.phonebook_id == ^phonebook_id
    page =
      Search.build_query(query, conn, params)
      |> Repo.paginate(params)

    page
  end
end
