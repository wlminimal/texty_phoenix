defmodule Texting.Messenger.Twilio do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User
  alias Texting.Messenger.Twilio

  schema "twilio" do
    field :account, :string
    field :token, :string
    field :msid, :string
    field :available_phone_number_count, :integer
    field :user_id, :integer
    belongs_to :user, User, define_field: false
  end

  def changeset(%Twilio{} = twilio, attrs) do
    twilio
    |> cast(attrs, [:account, :token, :msid, :available_phone_number_count, :user_id])
    #|> validate_required([:account, :token, :msid, :user_id])
  end
end
