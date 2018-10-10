defmodule Texting.Messenger.MessageStatus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Sales.Order
  alias Texting.Messenger.MessageStatus

  schema "message_status" do
    field :name, :string
    field :to, :string
    field :from, :string
    field :message, :string
    field :status, :string
    field :message_sid, :string
    field :account_sid, :string
    field :order_id, :integer

    belongs_to :order, Order, define_field: false
    timestamps()
  end

  def changeset(%MessageStatus{} = message_status, attrs) do
    message_status
    |> cast(attrs, [:name, :to, :from, :message, :status, :message_sid, :account_sid, :order_id])
    |> validate_required([:to])
    |> foreign_key_constraint(:order_id)
  end

end
