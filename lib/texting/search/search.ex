defmodule Texting.Search do
  use Inquisitor
  import Ecto.Query

  @whitelist ["name", "phone_number", "to", "by_status"]
  def build_query(query, term, value, _conn) when term in @whitelist do
    value = String.trim(value)

    # if term == "name" do
    #   value = "%" <> value <> "%"
    #   Ecto.Query.where(query, [u], ilike(u.name, ^value))
    # else
    #  # value = "1" <> value
    #   value = "%" <> value <> "%"
    #   Ecto.Query.where(query, [u], ilike(u.phone_number, ^value))
    # end

    cond do
      term == "name" ->
        value = "%" <> value <> "%"
        Ecto.Query.where(query, [u], ilike(u.name, ^value))

      term == "phone_number" ->
        value = "%" <> value <> "%"
        Ecto.Query.where(query, [u], ilike(u.phone_number, ^value))

      term == "to" ->
        value = "%" <> value <> "%"
        Ecto.Query.where(query, [u], ilike(u.to, ^value))
      term == "by_status" ->
        Ecto.Query.where(query, [u], u.status == ^value)
      true ->
        nil
    end
  end
end
