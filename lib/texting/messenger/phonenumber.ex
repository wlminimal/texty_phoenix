defmodule Texting.Messenger.Phonenumber do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User

  schema "phonenumbers" do
    field :account_sid, :string
    field :friendly_name, :string
    field :number, :string
    field :phonenumber_sid, :string
    field :user_id, :integer

    belongs_to :users, User, define_field: false
    timestamps()
  end

  @doc false
  def changeset(phonenumber, attrs) do
    phonenumber
    |> cast(attrs, [:number, :account_sid, :phonenumber_sid, :friendly_name])
    |> validate_required([:number, :account_sid, :phonenumber_sid, :friendly_name])
  end
end
