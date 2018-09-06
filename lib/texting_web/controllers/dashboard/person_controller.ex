defmodule TextingWeb.Dashboard.PersonController do
  use TextingWeb, :controller
  alias Texting.Contact
  alias Texting.Contact.Phonebook

  def action(conn, _) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(conn.params["phonebook_id"], user.id)
    arg_list = [conn, conn.params, phonebook]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def new(conn, _params, phonebook) do
    changeset = Contact.change_phonebook(%Phonebook{})
    render(conn, "new.html", changeset: changeset, phonebook: phonebook)
  end

  def create(conn, %{"person" => person_params}, phonebook) do
    user = conn.assigns.current_user
    # Check if user tries to add person to Unsubscriber phonebook
    IO.puts "++++++++Phonebook ID+++++++++++++"
    IO.inspect phonebook.id
    IO.puts "+++++++++++++Person Params+++++++++++++++++++++++"
    IO.inspect person_params
    IO.puts "+++++++++++++Person Params+++++++++++++++++++++++"
    with false <- Contact.is_unsubscriber_contact?(phonebook.id, user),
         false <- Contact.is_subscriber_contact?(phonebook.id, user) do
      case Contact.create_person(phonebook, user, person_params) do
        {:ok, _person} ->
          conn
          |> put_flash(:info, "New Contact created successfully")
          |> redirect(to: phonebook_path(conn, :show, phonebook.id))
        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html", changeset: changeset, phonebook: phonebook)
      end
    else
      true ->
        # Don't let the user add people to unsubscriber phonebook name
        conn
        |> put_flash(:error, "You can't add a contact to Unsubscriber or Subscriber Phonebook manually")
        |> redirect(to: phonebook_path(conn, :index))
    end
  end

  def create(conn, _, phonebook) do
    conn
    |> put_flash(:error, "Please Enter name and phone number correctly!")
    |> redirect(to: phonebook_person_path(conn, :new, phonebook.id))
  end

  def edit(conn, %{"id" => id}, phonebook) do
    person = Contact.get_person!(id, phonebook.id)
    changeset = Contact.change_person(person)
    # Phone number format change for display
    with_1_phone_number = changeset.data.phone_number
    {_, phone_number} = String.split_at(with_1_phone_number, 1)
    changeset = Ecto.Changeset.put_change(changeset, :phone_number, phone_number)
    render(conn, "edit.html", person: person, phonebook: phonebook, changeset: changeset)
  end

  def update(conn, %{"id" => id, "person" => person_params}, phonebook) do
    person = Contact.get_person!(id, phonebook.id)
    #user = conn.assigns.current_user
    case Contact.update_person(person, person_params) do
      {:ok, _person} ->
        conn
        |> put_flash(:info, "Contact updated successfully.")
        |> redirect(to: phonebook_path(conn, :show, phonebook))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Problems with your information.")
        |> render("edit.html", phonebook: phonebook, changeset: changeset, person: person)
    end
  end

  def delete(conn, %{"id" => id}, phonebook) do
    person = Contact.get_person!(id, phonebook.id)
    {:ok, _person} = Contact.delete_person(person)

    conn
    |> put_flash(:info, "Contact deleted successfully.")
    |> redirect(to: phonebook_path(conn, :show, phonebook))
  end

  # ADD Later
  def delete_selected(conn, %{"recipients_list" => recipients_list}) do

  end

end
