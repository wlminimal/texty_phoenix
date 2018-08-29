defmodule Texting.Sales.LineItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Sales.LineItem

  embedded_schema do
    field :person_id, :integer
    field :name, :string
    field :phone_number, :string
  end

  def changeset(%LineItem{} = line_item, attrs) do
    line_item
    |> cast(attrs, [:person_id, :name, :phone_number])
    |> validate_required([:person_id, :name, :phone_number])
  end
end
