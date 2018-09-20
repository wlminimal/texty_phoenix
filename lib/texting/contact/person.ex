defmodule Texting.Contact.Person do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Contact.{Person, Phonebook}
  alias Texting.Account.User

  schema "people" do
    field :name, :string
    field :phone_number, :string
    field :email, :string
    field :subscribed, :boolean
    field :previous_phonebook_id, :integer

    belongs_to :phonebook, Phonebook
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Person{} = person, attrs) do
    person
    |> cast(attrs, [:name, :phone_number, :email, :subscribed, :previous_phonebook_id])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number, name: :people_phone_number_phonebook_id_index)
    |> validate_format(:phone_number, ~r/^[0-9]+$/)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:phone_number, min: 11, max: 11)
  end
end
