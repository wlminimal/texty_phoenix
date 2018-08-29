defmodule Texting.Finance.Charge do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User
  alias Texting.Finance.Charge

  schema "charges" do
    field :charge_id, :string
    field :amount, :integer
    field :stripe_id, :string
    field :card, :string
    field :date, :naive_datetime
    field :description, :string
    field :user_id, :integer

    belongs_to :users, User, define_field: false
  end

  @doc false
  def changeset(%Charge{} = charge, attrs) do
    charge
    |> cast(attrs, [:charge_id, :amount, :stripe_id, :card, :date, :description, :user_id])
    |> validate_required([:charge_id, :amount, :stripe_id, :card, :date, :description, :user_id])
  end
end
