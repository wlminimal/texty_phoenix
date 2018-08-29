defmodule Texting.Finance.Stripe do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Finance.Stripe
  alias Texting.Account.User

  schema "stripe" do
    field :customer_id, :string
    field :subscription_id, :string
    field :plan_id, :string
    field :plan_name, :string
    field :user_id, :integer

    belongs_to :user, User, define_field: false

  end

  def changeset(%Stripe{} = stripe, attrs) do
    stripe
    |> cast(attrs, [:customer_id, :subscription_id, :plan_id, :plan_name, :user_id])
   # |> validate_required([:customer_id, :subscription_id, :plan_id, :plan_name, :user_id])
  end
end
