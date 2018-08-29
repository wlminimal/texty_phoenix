defmodule Texting.CsvFormatter do
  alias Texting.Contact

  def read!(filename) do
    filename
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.to_list()
  end

  def convert_to_person(attrs, phonebook, user) do
    phonebook
    |> Contact.create_person(user, attrs)
  end
end
