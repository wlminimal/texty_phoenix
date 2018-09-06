defmodule Texting.Account.WelcomeMessage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User
  alias Texting.Account.WelcomeMessage

  schema "welcome_message" do
    field :message, :string
    field :user_id, :integer
    belongs_to :user, User, define_field: false
  end

  def changeset(%WelcomeMessage{} = welcome_message, attrs) do
    welcome_message
    |> cast(attrs, [:message, :user_id])
  end
end
