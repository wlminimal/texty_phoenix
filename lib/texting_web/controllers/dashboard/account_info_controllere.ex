defmodule TextingWeb.Dashboard.AccountInfoController do
  use TextingWeb, :controller
  alias Texting.Account

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
end
