defmodule Texting.Search do
  use Inquisitor
  import Ecto.Query

  @whitelist ["name", "phone_number"]
  def build_query(query, term, value, _conn) when term in @whitelist do
    value = String.trim(value)

    if term == "name" do
      value = "%" <> value <> "%"
      Ecto.Query.where(query, [u], ilike(u.name, ^value))
    else
     # value = "1" <> value
      value = "%" <> value <> "%"
      Ecto.Query.where(query, [u], ilike(u.phone_number, ^value))
    end

  end
end
