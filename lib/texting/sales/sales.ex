defmodule Texting.Sales do
  alias Texting.Repo
  alias Texting.Sales.{Order, LineItem}
  import Ecto.Query


  def get_recipients_list_status_order(id, user_id) do
   # query = from r in Order, where: r.id == ^id and r.status == "In Recipients List"
    Order
    |> Repo.get_by(id: id, status: "In Recipients List", user_id: user_id)

  end

  def get_all_confirmed_status_order(user_id) do
    query = from o in Order, where: o.user_id == ^user_id and o.status == "Confirmed", order_by: [desc: o.inserted_at]
    Repo.all(query)
  end

  def get_all_confirmed_status_order(user_id, limit) do
    query = from o in Order, where: o.user_id == ^user_id and o.status == "Confirmed", order_by: [desc: o.inserted_at], limit: ^limit
    Repo.all(query)
  end

  def get_most_recent_order_by_type(user_id, message_type) do
    query = from o in Order, where: o.user_id == ^user_id and o.status == "Confirmed" and o.message_type == ^message_type, order_by: [desc: o.inserted_at], limit: 1
    Repo.all(query)
  end

  def get_most_recent_order(user_id) do
    query = from o in Order, where: o.user_id == ^user_id and o.status == "Confirmed", order_by: [desc: o.inserted_at], limit: 1
    Repo.all(query)
  end

  def get_all_confirmed_status_order_with_pagination(user_id, params) do
    query = from o in Order, where: o.user_id == ^user_id and o.status == "Confirmed", order_by: [desc: o.inserted_at]
    Repo.paginate(query, params)
  end

  def get_order_by_id(id, user_id) do
    query = from o in Order, where: o.id == ^id and o.user_id == ^user_id, preload: [:message_status]
    Repo.one(query)
  end

  def get_order_by_order_id(id) do
    query = from o in Order, where: o.id == ^id, preload: [:message_status]
    Repo.one(query)
  end

  def create_initial_order(user) do
    Order.changeset(%Order{}, %{status: "In Recipients List", counts: 0, user_id: user.id})
    |> Repo.insert!()
  end

  def update_order(changeset) do
    changeset
    |> Repo.update!
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    order
    |> Order.changeset(attrs)
  end

  def count_recipients(recipients_params, current_counts) do
    counts = Enum.count(recipients_params)
    current_counts + counts
  end

  def add_to_recipients(%Order{line_items: [], counts: current_counts} = recipients, recipients_params) do
    counts = count_recipients(recipients_params, current_counts)
    attrs = %{line_items: recipients_params, counts: counts}
    update_recipients(recipients ,attrs)
  end

  def add_to_recipients(%Order{line_items: exisiting_recipients, counts: _current_counts} = recipients, new_recipients) do
    #new_item = %{person_id: String.to_integer(recipients_params["person_id"])}
    exisiting_recipients = exisiting_recipients |> Enum.map(&Map.from_struct/1)
    attrs = remove_duplicate_recipients(exisiting_recipients, new_recipients)
    update_recipients(recipients, attrs)
  end

  @doc """
  Before Add all person from phonebook to Recipients List
  Need to change %Person{} to %{}
  and then call add_to_recipients function in controller
  """
  @spec struct_to_map_from_person(list) :: Map
  def struct_to_map_from_person(people) do
    line_items =
      people
      |> Enum.map(fn p ->
          %LineItem{name: p.name, person_id: p.id, phone_number: p.phone_number}
         end)
      |> Enum.map(&Map.from_struct/1)

  end

  def update_recipients(recipients, attrs) do
    recipients
    |> Order.changeset(attrs)
    |> Repo.update
  end

  def delete_recipient(%{line_items: line_items} = recipients, id) do
    line_items = line_items |> Enum.map(&Map.from_struct/1)
    recipient = Enum.find(line_items, & &1.id == id)
    new_line_items = line_items |> List.delete(recipient)
    counts = Enum.count(new_line_items)
    attrs = %{line_items: new_line_items, counts: counts}
    update_recipients(recipients, attrs)
  end

  def delete_many_recipients(%{line_items: line_items} = recipients, delete_list) do
    # convert list to MapSet for better performance
    line_items_mapset =
      Enum.map(line_items, fn a -> a end)
      |> MapSet.new
    ids =
      Enum.map(delete_list, fn a -> a end)
      |> MapSet.new
    new_line_items =
      Enum.reject(line_items_mapset, & &1.id in ids)
      |> Enum.map(&Map.from_struct/1)

    counts = Enum.count(new_line_items)
    attrs = %{line_items: new_line_items, counts: counts}
    update_recipients(recipients, attrs)
  end

  @doc """
  Confirming Order
  status: "Confirmed"
  message_type: "sms or mms"
  total: "1.50"
  message: "Sent message"
  """
  def confirm_order(%Order{} = recipients, attrs) do
    attrs = Map.put(attrs, "status", "Confirmed")
    recipients
    |> Order.checkout_changeset(attrs)
    |> Repo.update()
  end


  def change_recipients(%Order{} = recipients) do
    Order.changeset(recipients, %{})
  end

  defp remove_duplicate_recipients(exisiting_recipients, new_recipients) do
    recipients_list = exisiting_recipients ++ new_recipients
    ready_recipients = recipients_list |> Enum.uniq_by(& &1.name)
    counts = Enum.count(ready_recipients)
    attrs = %{line_items: ready_recipients, counts: counts}
    attrs
  end
end
