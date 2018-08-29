defmodule TextingWeb.Plugs.AuthorizeAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]
  alias TextingWeb.Router.Helpers

  def init(_opts), do: nil

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = conn.assigns.current_user

    with true <- user_id == user.id,
         true <- user.admin do
          conn
    else
      false ->
        conn
        |> put_flash(:error, "You are not allowed")
        |> redirect(to: Helpers.dashboard_path(conn, :new))
        |> halt()
    end
  end
end
