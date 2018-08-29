defmodule Texting.Contact.Phonebook do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Contact.{Phonebook, Person}
  alias Texting.Account.User


  schema "phonebooks" do
    field :name, :string

    has_many :people, Person
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Phonebook{} = phonebook, attrs) do
    phonebook
    |> cast(attrs, [:name])
    |> unique_constraint(:name, name: :phonebooks_name_user_id_index)
    |> validate_required([:name])
    |> no_assoc_constraint(:people)

  end
end
