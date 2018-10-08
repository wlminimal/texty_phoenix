defmodule Texting.Contact.SearchContact do
  import Ecto.Query, warn: false
  alias Texting.Repo
  alias Texting.Contact.Person
  alias Texting.Messenger.MessageStatus
  alias Texting.Search

  def get_search_results_in_phonebook(conn, params, phonebook_id) do
    query = from p in Person, where: p.phonebook_id == ^phonebook_id
    page =
      Search.build_query(query, conn, params)
      |> Repo.paginate(params)

    page
  end


  def get_search_results_in_camp_history(conn, params, campaign_id) do
    query = from m in MessageStatus, where: m.order_id == ^campaign_id
    page =
      Search.build_query(query, conn, params)
      |> Repo.paginate(params)
    IO.puts "+++++++++ Search  ++++++++++++++"
    IO.inspect page
    page
  end
end
