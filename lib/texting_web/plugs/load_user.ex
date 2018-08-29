defmodule TextingWeb.Plugs.LoadUser do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2, put_flash: 3]

  alias Texting.Account

  alias TextingWeb.Router.Helpers

  def init(_opts), do: nil

  def call(conn, _opts) do
    case user_id = get_session(conn, :user_id) do
    	user_id when user_id != nil ->
    		user = Account.get_user_by_id(user_id)
    		assign(conn, :current_user, user)
    	user_id when is_nil(user_id) ->
    		conn
    		|> put_flash(:error, "You must sign in first")
    		|> redirect(to: Helpers.sign_in_path(conn, :new))
        |> halt()
    end
  end
end
