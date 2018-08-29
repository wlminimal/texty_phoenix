defmodule Texting.Finance.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User
  alias Texting.Finance.Invoice

  schema "invoices" do
    field :invoice_id, :string
    field :amount, :integer
    field :receipt_number, :string
    field :description, :string
    field :type, :string
    field :date, :naive_datetime
    field :user_id, :integer
    belongs_to :users, User, define_field: false
  end

  def changeset(%Invoice{} = invoice, attrs) do
    invoice
    |> cast(attrs, [:invoice_id, :amount, :description, :type, :date, :user_id, :receipt_number])
    |> validate_required([:invoice_id, :amount, :description, :type, :date, :user_id, :receipt_number])
  end
end
