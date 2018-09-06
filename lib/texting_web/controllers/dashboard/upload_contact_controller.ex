defmodule TextingWeb.Dashboard.UploadContactController do
  use TextingWeb, :controller

  alias Texting.CsvFormatter
  alias Texting.Contact
  def new(conn, _params) do
    # Get phonebook list and
    # Make list ["Phonebook_name": "phonebook_id"]
    user = conn.assigns.current_user
    phonebooks =
      Contact.list_phonebooks(user.id)
      |> Enum.reject(& &1.name == "Unsubscriber")
      |> Enum.reject(& &1.name == "Subscriber")
    render conn, "new.html", phonebooks: phonebooks
  end

  def upload(conn, %{"name" => phonebook_name, "contact_csv" => %Plug.Upload{path: path}}) do
    user = conn.assigns.current_user
    try do
      contacts_map = CsvFormatter.read!(path)
      case Contact.create_phonebook(user, %{"name" => phonebook_name}) do
        {:ok, phonebook} ->
          Enum.map(contacts_map, &CsvFormatter.convert_to_person(&1, phonebook, user))
          conn
          |> put_flash(:info, "Contacts created successfully. Check your phonebook!")
          |> redirect(to: phonebook_path(conn, :index))
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Phonebook name '#{phonebook_name}' already taken, Please use other name")
          |> redirect(to: upload_contact_path(conn, :new))
      end
    rescue
      _e in CSV.RowLengthError ->
        conn
        |> put_flash(:error, "Please upload only .csv format or check your file contents")
        |> redirect(to: upload_contact_path(conn, :new))
      _ ->
        conn
        |> put_flash(:error, "Please upload only .csv format or check your file contents")
        |> redirect(to: upload_contact_path(conn, :new))
    end
  end

  def upload(conn, %{"phonebook_id" => phonebook_id, "contact_csv" => %Plug.Upload{path: path}}) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!( phonebook_id, user.id)
    try do
      contacts_map = CsvFormatter.read!(path)
      Enum.map(contacts_map, &CsvFormatter.convert_to_person(&1, phonebook, user))
      conn
      |> put_flash(:info, "Contacts added to #{phonebook.name} successfully. Check your phonebook!")
      |> redirect(to: phonebook_path(conn, :index))
    rescue
      _e in CSV.RowLengthError ->
        conn
        |> put_flash(:error, "Please upload only .csv format or check your file contents")
        |> redirect(to: upload_contact_path(conn, :new))
      _ ->
        conn
        |> put_flash(:error, "Please upload only .csv format or check your file contents")
        |> redirect(to: upload_contact_path(conn, :new))
    end
  end

  def upload(conn, _), do: conn |> redirect(to: upload_contact_path(conn, :new))
end
