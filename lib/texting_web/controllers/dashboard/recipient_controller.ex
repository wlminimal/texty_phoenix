defmodule TextingWeb.Dashboard.RecipientController do
  use TextingWeb, :controller

  alias Texting.Sales
  alias Texting.Contact
  alias Texting.Formatter

  import Ecto.Query

  @doc """
  Add selected person to recipients list.
  """
  def add(conn, %{ "recipients_list" => recipients_params }) do
    count = length(recipients_params)
    recipients_params = recipients_params
      |> Enum.map(fn r -> String.split(r, ",")end)
      |> change_list_to_map()

    recipients = conn.assigns.recipients
    case Sales.add_to_recipients(recipients, recipients_params) do
      {:ok, _order} ->
        message = "#{count} contacts added to recipients list! Remember, Duplicate phone number will not be added."
        conn
        |> put_flash(:info, message)
        |> redirect(to: recipient_path(conn, :show))
      {:error, reason} ->
        IO.puts "++++++++++++++++++REASON+++++++++++++++++++"
        IO.inspect reason
        conn
        |> put_flash(:error, "Error adding to recipients list!")
        |> redirect(to: phonebook_path(conn, :index))
    end
  end

  @doc """
  Add all contacts from phonebook in /dashboard/phonebooks
  """
  def add(conn, %{ "phonebook_recipients" => %{"phonebook_id" => phonebook_id }}) do

    people = Contact.get_people(phonebook_id)
    recipients = conn.assigns.recipients
    line_items = Sales.struct_to_map_from_person(people)
    count = length(line_items)
    # put phonebook id into session
    conn = put_session(conn, :phonebook_id, phonebook_id)
    case Sales.add_to_recipients(recipients, line_items) do
      {:ok, _order} ->
        message = "#{count} contacts added to recipients list! Remember, Duplicate phone number will not be added."
        conn
        |> put_flash(:info, message)
        |> redirect(to: recipient_path(conn, :show))
      {:error, _order} ->
        conn
        |> put_flash(:error, "Error adding to recipients list!")
        |> redirect(to: phonebook_path(conn, :index))

    end
  end

  def add(conn, params) do
    IO.puts "++++++++++++++ recipients params +++++++++++++++"
    IO.inspect params
    IO.puts "++++++++++++++ recipients params +++++++++++++++"
    conn
    |> put_flash(:error, "Please Check at least one contact.")
    |> redirect(to: recipient_path(conn, :show))
  end


  def show(conn, _params) do
    # Get Recipients from assigns (Plugs.FetchRecipients)
    recipients = conn.assigns.recipients
    # Get list items from database use fragment and unnest
    list_line_items = from r in Texting.Sales.Order, where: r.id == ^recipients.id and r.status == "In Recipients List", select: fragment("unnest(line_items)")
    list_line_items = list_line_items
      |> Texting.Repo.all
      |> Enum.map(&Formatter.convert_map_to_struct/1)
      |> Enum.map(&struct(Texting.Sales.LineItem, &1))

    page = Texting.Repo.paginate(list_line_items, conn.params)
    phonebook_id = get_session(conn, :phonebook_id)
    render conn, "show.html",
      recipients: recipients,
      phonebook_id: phonebook_id,
      page: page
  end

  def delete(conn, %{"id" => id}) do
    recipients = conn.assigns.recipients
    phonebook_id = get_session(conn, :phonebook_id)
    case Sales.delete_recipient(recipients, id) do
      {:ok, recipients} ->
        conn
        |> put_session(:recipients_id, recipients.id)
        |> assign(:recipients, recipients)
        |> redirect(to: recipient_path(conn, :show, recipients: recipients, phonebook_id: phonebook_id))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Can't delete recipient")
        |> redirect(to: recipient_path(conn, :show, phonebook_id: phonebook_id))
    end

  end

  def delete_selected(conn, %{"recipients_list" => recipients_list}) do
    IO.inspect recipients_list
    recipients = conn.assigns.recipients
    phonebook_id = get_session(conn, :phonebook_id)
    case Sales.delete_many_recipients(recipients, recipients_list) do
      {:ok, new_recipients} ->
        conn
        |> assign(:recipients, new_recipients)
        |> put_flash(:info, "Contact(s) are removed from Recipients List.")
        |> redirect(to: recipient_path(conn, :show, phonebook_id: phonebook_id))
      {:error, _} ->
        conn
        |> put_flash(:error, "Can't delete recipients from list.")
        |> redirect(to: recipient_path(conn, :show))
    end
    redirect(conn, to: recipient_path(conn, :show, phonebook_id: phonebook_id))
  end

  def delete_selected(conn, _) do
    phonebook_id = get_session(conn, :phonebook_id)
    conn
    |> put_flash(:error, "Please select at least 1 recipient.")
    |> redirect(to: recipient_path(conn, :show, phonebook_id: phonebook_id))
  end

  def change_list_to_map(list) do
    list
    |> Enum.map(
        fn l ->
          [person_id, name, phone_number] = l
          %{person_id: person_id, name: name, phone_number: phone_number}
        end )
  end
end
