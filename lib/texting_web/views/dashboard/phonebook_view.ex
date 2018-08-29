defmodule TextingWeb.Dashboard.PhonebookView do
  use TextingWeb, :view
  import Scrivener.HTML
  import TextingWeb.Dashboard.PersonView, only: [display_phone_number: 1]
  alias Texting.Contact

  def phonebook_total(phonebook_id) do
    people = Contact.get_people(phonebook_id)
    Enum.count(people)
  end
end
