defmodule Texting.Cronjob do
  alias Timex
  alias Texting.Repo
  import Ecto.Query
  alias Texting.Sales.Order
  alias Texting.Bitly


  def remove_orders_and_bitly do
    two_days_ago = Timex.subtract(Timex.now, Timex.Duration.from_days(2))
    query =  from o in Order, where: o.status == "In Recipients List" and o.inserted_at <= ^two_days_ago
    query
    |> Repo.all()
    |> Enum.map(&Repo.delete!/1)
  end

  def remove_bitly do
    two_days_ago = Timex.subtract(Timex.now, Timex.Duration.from_days(2))
    query = from b in Bitly, where: b.status == "Not Saved" and b.inserted_at <= ^two_days_ago
    query
    |> Repo.all()
    |> Enum.map(&Repo.delete!/1)
  end
end
