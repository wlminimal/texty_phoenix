defmodule TextingWeb.Dashboard.CsvExportController do
  use TextingWeb, :controller
  alias Texting.CsvFormatter
  alias Texting.Contact


  def export(conn, %{"id" => phonebook_id}) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"contacts.csv\"")
    |> send_resp(200, export_contacts_from_phonebook(phonebook_id))
  end

  def export_contacts_from_phonebook(phonebook_id) do
    Contact.get_people(phonebook_id)
    |> CsvFormatter.write()
  end
end
