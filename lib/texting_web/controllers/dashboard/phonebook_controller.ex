defmodule TextingWeb.Dashboard.PhonebookController do
  use TextingWeb, :controller
  alias Texting.Contact
  alias Texting.Contact.Phonebook
  alias TextingWeb.Plugs.AuthorizeUser
  alias Texting.Contact.SearchContact
  alias Texting.Contact.Person
  alias Texting.Search

  plug AuthorizeUser when action in [:new, :create, :show, :edit, :update, :delete]


  def index(conn, _params) do
    user = conn.assigns.current_user
    Contact.get_or_create_unsubscribed_contact(user)
    Contact.get_or_create_subscribed_contact(user)
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

  @doc """
  Search by name
  """
  def show(conn, %{"id" => id, "name" => name} = params) do
    IO.puts "+++++++++ name ++++++++++++="
    IO.inspect name
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(id, user.id)
    # put a phonebook id in session for recipient page for continue adding button.
    conn = put_session(conn, :phonebook_id, phonebook.id)
    # search by params
    page = SearchContact.get_search_results_in_phonebook(conn, params, phonebook.id)

    render(conn, "search_results.html", phonebook: phonebook, people: page)
  end

  @doc """
  Search by phone_number
  """
  def show(conn, %{"id" => id, "phone_number" => phone_number} = params) do
    IO.puts "+++++++++ phone_number ++++++++++++="
    IO.inspect phone_number
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(id, user.id)
    # put a phonebook id in session for recipient page for continue adding button.
    conn = put_session(conn, :phonebook_id, phonebook.id)
    # pass the params for pagination
    page = SearchContact.get_search_results_in_phonebook(conn, params, phonebook.id)
    IO.puts "+++++++++++++++ query param +++++++++++++++++++"
    IO.inspect conn.query_params
    render(conn, "search_results.html", phonebook: phonebook, people: page )
  end

  @doc """
  Default show function
  Show contacts in phonebook
  """
  def show(conn, %{"id" => id} = params) do
    IO.puts "+++++++++ default show function ++++++++++++="
    IO.inspect params
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

    with false <- Contact.is_unsubscriber_contact?(id, user),
         false <- Contact.is_subscriber_contact?(id, user) do
     phonebook = Contact.get_phonebook!(id, user.id)
     changeset = Contact.change_phonebook(phonebook)
     render(conn, "edit.html", phonebook: phonebook, changeset: changeset)
    else
     true ->
       # Don't let the user edit unsubscriber phonebook name
       conn
       |> put_flash(:info, "You can't edit Unsubscriber Phonebook.")
       |> redirect(to: phonebook_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "phonebook" => phonebook_params}) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(id, user.id)

    with false <- Contact.is_unsubscriber_contact?(id, user),
         false <- Contact.is_subscriber_contact?(id, user) do
      case Contact.update_phonebook(phonebook, phonebook_params) do
        {:ok, phonebook} ->
          conn
          |> put_flash(:info, "Phonebook updated successfully.")
          |> redirect(to: phonebook_path(conn, :show, phonebook))
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", phonebook: phonebook, changeset: changeset)
      end
    else
     true ->
       # Don't let the user edit unsubscriber phonebook name
       conn
       |> put_flash(:info, "You can't edit Unsubscriber Phonebook.")
       |> redirect(to: phonebook_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with false <- Contact.is_unsubscriber_contact?(id, user),
         false <- Contact.is_subscriber_contact?(id, user) do
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
         else
          true ->
            # Don't let the user edit unsubscriber phonebook name
            conn
            |> put_flash(:info, "You can't delete Unsubscriber Phonebook.")
            |> redirect(to: phonebook_path(conn, :index))
         end
  end

end
