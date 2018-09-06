defmodule Texting.Contact do
  @moduledoc """
  The Contact context.
  """

  import Ecto.Query, warn: false
  import Ecto
  alias Texting.Repo

  alias Texting.Contact.{Phonebook, Person}
  alias Texting.Formatter

  def list_phonebooks(user_id) do
    query = from p in Phonebook, where: p.user_id == ^user_id
    Repo.all(query)
  end

  def get_phonebook!(phonebook_id, user_id) do
    query = from p in Phonebook, where: p.user_id == ^user_id

    Repo.get!(query, phonebook_id)
  end

  def get_phonebook_by_name(phonebook_name, user_id) do
    query = from p in Phonebook, where: p.name == ^ phonebook_name and p.user_id == ^user_id
    Repo.one(query)
  end

  def create_phonebook(user, attrs \\ %{}) do
    build_assoc(user, :phonebooks)
    |> Phonebook.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_unsubscribed_contact(user) do
    case get_phonebook_by_name("Unsubscriber", user.id) do
      nil ->
        # create unsubscribed phonebook
        {:ok, unsubscribed_phonebook} = build_assoc(user, :phonebooks)
          |> Phonebook.changeset(%{"name" => "Unsubscriber"})
          |> Repo.insert()
        unsubscribed_phonebook
      unsubscribed_phonebook ->
        unsubscribed_phonebook
    end
  end

  def update_phonebook(%Phonebook{} = phonebook, attrs) do
    phonebook
    |> Phonebook.changeset(attrs)
    |> Repo.update()
  end

  def delete_phonebook(%Phonebook{} = phonebook) do
    phonebook
    |> change_phonebook()
    |> Repo.delete()
  end

  def change_phonebook(%Phonebook{} = phonebook) do
    Phonebook.changeset(phonebook, %{})
  end

  ## PERSON

  def get_people(phonebook_id, params) do
    query = from p in Person, where: p.phonebook_id == ^phonebook_id
    Repo.paginate(query, params)
  end

  def get_people_by_phonenumber(user_id, phonenumber) do
    query = from p in Person, where: p.user_id == ^user_id and p.phone_number == ^phonenumber
    Repo.all(query)
  end

  def get_people(phonebook_id) do
    Repo.all(from p in Person, where: p.phonebook_id == ^phonebook_id)
  end

  def get_all_people_count(user_id) do
    query = from p in Person, where: p.user_id == ^user_id
    query
    |> Repo.all
    |> Enum.count
  end

  def get_person!(person_id, phonebook_id) do
    query = from p in Person, where: p.phonebook_id == ^phonebook_id
    Repo.get!(query, person_id)
  end

  def create_person(phonebook, user, attrs \\ %{}) do
    %{"phone_number" => phone_number, "name" => name} = attrs
    # if name is empty, enter default name "No name"
    name =
      if name == "" do
        "No name"
      end
    # Change phone number format to 1 213 333 3458 with no space
    formatted_phone_number = Formatter.phone_number_formatter(phone_number)
    new_attrs = %{attrs | "phone_number" => formatted_phone_number, "name" => name}
    IO.puts "+++++++++++new_attrs+++++++++++++"
    IO.inspect new_attrs

    changeset = build_assoc(phonebook, :people)
      |> Person.changeset(new_attrs)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Ecto.Changeset.put_change(:previous_phonebook_id, phonebook.id)
    case Repo.insert(changeset) do
      {:ok, person} -> {:ok, person}
      {:error, changeset} -> {:error, Ecto.Changeset.put_change(changeset, :phone_number, phone_number) }
    end
  end


  def update_person(%Person{} = person, attrs) do

    %{"phone_number" => phone_number, "name" => name} = attrs
    # Change phone number format to 1 213 333 3458 with no space
    formatted_phone_number = Formatter.phone_number_formatter(phone_number)
    new_attrs = %{attrs | "phone_number" => formatted_phone_number, "name" => name}

    changeset = Person.changeset(person, new_attrs)
    case Repo.update(changeset) do
      {:ok, person} -> {:ok, person}
      {:error, changeset} ->
        # replace phone_number without "1"
        changeset = Ecto.Changeset.put_change(changeset, :phone_number, phone_number)
        {:error, changeset}
    end

    # if subscribed == "false" do
    #   # Move person to unsubscribed contact
    #   unsubscriber_phonebook = get_or_create_unsubscribed_contact(user)
    #   changeset = Person.changeset(person, new_attrs)
    #   new_changeset = Ecto.Changeset.put_change(changeset, :phonebook_id, unsubscriber_phonebook.id)

    #   case Repo.update(new_changeset) do
    #     {:ok, person} -> {:ok, person}
    #     {:error, changeset} ->
    #       # replace phone_number without "1"
    #       changeset = Ecto.Changeset.put_change(changeset, :phone_number, phone_number)
    #       {:error, changeset}
    #   end
    # else
    #   changeset = Person.changeset(person, new_attrs)
    #   case Repo.update(changeset) do
    #     {:ok, person} -> {:ok, person}
    #     {:error, changeset} ->
    #       # replace phone_number without "1"
    #       changeset = Ecto.Changeset.put_change(changeset, :phone_number, phone_number)
    #       {:error, changeset}
    #   end
    # end

  end

  def delete_person(%Person{} = person) do
    person
    |> change_person()
    |> Repo.delete()
  end

  def change_person(%Person{} = person) do
    Person.changeset(person, %{})
  end

end
