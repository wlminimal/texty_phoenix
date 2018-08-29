defmodule TextingWeb.PageController do
  use TextingWeb, :controller
  alias Payment
  alias Texting.Mailer
  alias TextingWeb.Email

  def index(conn, _params) do
    render conn, "index.html", text: "Hello from Drab!"
  end

  def create(conn, %{"contact_form" => %{"email" => email, "message" => message, "name" => name}}) do
    # Send email to admin...
    Email.contact_us_email(email, name, message) |> Mailer.deliver_later
    conn
    |> redirect(to: page_path(conn, :index))
  end
end
