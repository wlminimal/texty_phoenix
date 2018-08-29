defmodule TextingWeb.Dashboard.PhonenumberController do
  use TextingWeb, :controller

  def new(conn, _params) do
    user = conn.assigns.current_user
    render conn, "new.html", user: user
  end
end
