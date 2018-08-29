defmodule Texting.Admin do
  import Ecto.Query
  alias Texting.Repo
  alias Texting.Account.User

  def get_all_user(params) do
    query = from u in User, preload: [:stripe]
    Repo.paginate(query, params)
  end
end
