defmodule TextingWeb.Dashboard.AccountInfoController do
  use TextingWeb, :controller
  alias Texting.Account
  alias Texting.Account.WelcomeMessage

  def index(conn, _params) do
    user = conn.assigns.current_user
    render conn, "index.html", user: user
  end

  def edit(conn, %{"id" => id}) do
    user = Account.get_user_by_id(id)
    changeset = Account.change_user(user)

    render conn, "edit.html", changeset: changeset
  end

  def update(conn, %{"account_info" => params}) do
    user = conn.assigns.current_user
    changeset = Account.change_user(user, params)
    case Account.update_user(changeset) do
      _user ->
        conn
        |> put_flash(:info, "Account information updated!")
        |> redirect(to: account_info_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Somthing wrong. Please try again")
        |> redirect(to: account_info_path(conn, :edit))
    end

  end

  def new_welcome_message(conn, _params) do
    user = conn.assigns.current_user
    welcome_message = Account.get_welcome_message_by_user_id(user)
    if welcome_message == nil do
      changeset = Account.change_welcome_message(%WelcomeMessage{})
      render conn, "new_welcome_message.html", changeset: changeset
    else
      conn
      |> put_flash(:info, "You have a welcome message, Try to edit it")
      |> redirect(to: account_info_path(conn, :index))
    end

  end

  def create_welcome_message(conn, %{"welcome_message" => %{"message" => message}}) do
    user = conn.assigns.current_user
    Account.create_welcome_message(user, %{message: message})
    conn
    |> redirect(to: account_info_path(conn, :index))
  end

  def edit_welcome_message(conn, _params) do
    user = conn.assigns.current_user
    changeset = Account.change_welcome_message(user.welcome_message)
    render conn, "edit_welcome_message.html", changeset: changeset
  end

  def update_welcome_message(conn, %{"welcome_message" => %{"message" => message}}) do
    user = conn.assigns.current_user
    changeset = Account.change_welcome_message(user.welcome_message, %{message: message})
    IO.puts "++++++++++++++++++++++++++++++changeset++++++++++="
    IO.inspect changeset
    Account.update_welcome_message(changeset)
    conn
    |> redirect(to: account_info_path(conn, :index))
  end
end
