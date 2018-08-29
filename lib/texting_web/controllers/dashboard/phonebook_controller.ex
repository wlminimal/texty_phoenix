defmodule TextingWeb.Dashboard.PhonebookController do
  use TextingWeb, :controller
  alias Texting.Contact
  alias Texting.Contact.Phonebook
  alias TextingWeb.Plugs.AuthorizeUser

  plug AuthorizeUser when action in [:new, :create, :show, :edit, :update, :delete]

  def index(conn, _params) do
    user = conn.assigns.current_user
    unsubscribed_phonebook = Contact.get_phonebook_by_name("Unsubscriber", user.id)
    if unsubscribed_phonebook == nil do
      Contact.create_phonebook(user, %{name: "Unsubscriber"})
    end
    phonebooks = Contact.list_phonebooks(user.id)
    render(conn, "index.html", phonebooks: phonebooks)
  end

  def new(conn, _params) do
    changeset = Contact.change_phonebook(%Phonebook{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"phonebook" => phonebook_params}) do
    user = conn.assigns.current_user
    case Contact.create_phonebook(user, phonebook_params) do

      {:ok, phonebook} ->
        conn
        |> put_flash(:info, "Phonebook created successfully")
        |> redirect(to: phonebook_path(conn, :show, phonebook))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # Show Contact List
  def show(conn, %{"id" => id} = params) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(id, user.id)
    # put a phonebook id in session for recipient page for continue adding button.
    conn = put_session(conn, :phonebook_id, phonebook.id)
    # pass the params for pagination
    page = Contact.get_people(phonebook.id, params)
    render(conn, "show.html", phonebook: phonebook, people: page)
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    case is_unsubscriber_contact?(id, user) do
      true ->
        # Don't let the user edit unsubscriber phonebook name
        conn
        |> put_flash(:info, "You can't edit Unsubscriber Phonebook.")
        |> redirect(to: phonebook_path(conn, :index))
      false ->
        phonebook = Contact.get_phonebook!(id, user.id)
        changeset = Contact.change_phonebook(phonebook)
        render(conn, "edit.html", phonebook: phonebook, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "phonebook" => phonebook_params}) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(id, user.id)
    case is_unsubscriber_contact?(id, user) do
      true ->
        # Don't let the user edit unsubscriber phonebook name
        conn
        |> put_flash(:info, "You can't edit Unsubscriber Phonebook.")
        |> redirect(to: phonebook_path(conn, :index))
      false ->
        case Contact.update_phonebook(phonebook, phonebook_params) do
          {:ok, phonebook} ->
            conn
            |> put_flash(:info, "Phonebook updated successfully.")
            |> redirect(to: phonebook_path(conn, :show, phonebook))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", phonebook: phonebook, changeset: changeset)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case is_unsubscriber_contact?(id, user) do
      true ->
        # Don't let the user edit unsubscriber phonebook name
        conn
        |> put_flash(:info, "You can't delete Unsubscriber Phonebook.")
        |> redirect(to: phonebook_path(conn, :index))
      false ->
        phonebook = Contact.get_phonebook!(id, user.id)
      case Contact.delete_phonebook(phonebook) do
        {:ok, _phonebook} ->
          conn
          |> put_flash(:info, "Your phonebook is deleted.")
          |> redirect(to: phonebook_path(conn, :index))
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Phonebook can not be deleted. Because Phonebook has contacts. Please delete contacts first.")
          |> redirect(to: phonebook_path(conn, :index))
      end
    end
  end
  def is_unsubscriber_contact?(phonebook_id, user) when is_binary(phonebook_id) do
    unsubscribed_phonebook = Contact.get_phonebook_by_name("Unsubscriber", user.id)
    {phonebook_id, ""} = Integer.parse(phonebook_id)
    phonebook_id == unsubscribed_phonebook.id
  end

  def is_unsubscriber_contact?(phonebook_id, user) do
    unsubscribed_phonebook = Contact.get_phonebook_by_name("Unsubscriber", user.id)
    phonebook_id == unsubscribed_phonebook.id
  end
end
