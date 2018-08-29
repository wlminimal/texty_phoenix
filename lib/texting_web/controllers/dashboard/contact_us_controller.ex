defmodule TextingWeb.Dashboard.ContactUsController do
  use TextingWeb, :controller
  alias Texting.Mailer
  alias TextingWeb.Email


  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, %{"contact_us" => %{"name" => name, "email" => email, "message" => message}} = _params) do

    Email.contact_us_email(email, name, message) |> Mailer.deliver_later
    conn
    |> put_flash(:info, "Thanks for contacting us. We will get back to you within 24 hours.")
    |> redirect(to: contact_us_path(conn, :index))
  end
end
