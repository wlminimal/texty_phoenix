defmodule Texting.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Contact.{Phonebook, Person}
  alias Texting.Sales.Order
  alias Texting.Messenger.{Twilio, Phonenumber}
  alias Texting.Finance.Stripe
  alias Texting.Account.WelcomeMessage

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :token, :string
    field :last_login, :naive_datetime
    field :phone_number, :string
    field :phone_verified, :boolean
    field :credits, :integer
    field :email_verified, :boolean
    field :admin, :boolean

    has_one :welcome_message, WelcomeMessage
    has_one :twilio, Twilio
    has_one :stripe, Stripe
    has_many :phonebooks, Phonebook
    has_many :phonenumbers, Phonenumber
    has_many :orders, Order
    has_many :people, Person

    timestamps()
  end


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :first_name, :last_name, :phone_number, :phone_verified, :credits, :email_verified, :admin, :last_login])
    |> validate_required([:email, :first_name, :last_name])
    # |> validate_format(:phone_number, ~r/^[2-9]\d{2}-\d{3}-\d{4}$/)

  end

 # def oauth_changeset(struct, params \\ %{}) do
  #   struct
  #   |> cast(params, [:email, :first_name, :last_name, :token, :phone_number])
  #   |> validate_required([:email, :first_name, :last_name])
  # end

end
