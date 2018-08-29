defmodule TextingWeb.Plugs.AuthorizeUser do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias TextingWeb.Router.Helpers

  def init(_opts), do: nil

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = conn.assigns.current_user
    if user_id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify.")
      |> redirect(to: Helpers.dashboard_path(conn, :new))
      |> halt()
    end
  end
end
