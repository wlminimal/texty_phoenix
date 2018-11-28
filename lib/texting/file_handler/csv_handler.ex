defmodule Texting.FileHandler.CsvHandler do
  alias Texting.Contact
  alias Texting.Messenger
  alias Texting.Formatter

  def read!(filename) do
    filename
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.to_list()

    # |> filter_landline_number()
  end

  @doc """
    Write csv but without header. If I include header then sort, header will not be
    header. TODO: Find to way to add header after sorting
  """
  # def write(people) do
  #   [["name", "phone_number"]]
  #   |> Stream.concat(people |> Stream.map(&[&1.name, Formatter.remove_international_code(&1.phone_number)]))
  #   |> CSV.encode()
  #   |> Enum.sort()
  #  # |> Enum.into(File.stream!("contacts.csv"))
  # end

  def write(people) do
    people
    |> Stream.map(&[&1.name, Formatter.remove_international_code(&1.phone_number)])
    |> CSV.encode()
    |> Enum.sort()

    # |> Enum.into(File.stream!("contacts.csv"))
  end

  def convert_to_person(attrs, phonebook, user) do
    phonebook
    |> Contact.create_person(user, attrs)
  end

  @doc """
  contacts = list of maps
  """
  def filter_landline_number(contacts) do
    Enum.reject(contacts, &Messenger.is_landline_number?(&1["phone_number"]))
  end
end
