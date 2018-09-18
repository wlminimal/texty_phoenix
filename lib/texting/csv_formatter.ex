defmodule Texting.CsvFormatter do
  alias Texting.Contact
  alias Texting.Messenger

  def read!(filename) do
    filename
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.to_list()
    |> filter_landline_number()
  end

  def convert_to_person(attrs, phonebook, user) do
    phonebook
    |> Contact.create_person(user, attrs)
  end

  @doc"""
  contacts = list of maps
  """
  def filter_landline_number(contacts) do
    Enum.reject(contacts, &Messenger.is_landline_number?(&1["phone_number"]))
  end
end
