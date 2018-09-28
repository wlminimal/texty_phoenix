defmodule TextingWeb.Dashboard.CsvExportController do
  use TextingWeb, :controller
  alias Texting.FileHandler.CsvHandler
  alias Texting.Contact

  def export(conn, %{"id" => phonebook_id}) do
    send_download(
      conn,
      {:binary, export_contacts_from_phonebook(phonebook_id)},
      content_type: "application/csv",
      filename: "contacts.csv"
    )
  end

  def export_contacts_from_phonebook(phonebook_id) do
    Contact.get_people(phonebook_id)
    |> CsvHandler.write()
  end

end
