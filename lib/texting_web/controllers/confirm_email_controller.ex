defmodule TextingWeb.ConfirmEmailController do
  use TextingWeb, :controller
  alias Texting.Account
  alias Texting.Mailer
  alias TextingWeb.Email

  def new(conn, _param) do
    render conn, "new.html"
  end

  def create(conn, %{"confirm" => %{"email" => email}}) do
    # check if email is registered in database
    case Account.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "You are not registered. Please sign up.")
        |> redirect(to: sign_up_path(conn, :new))
      user   ->
        case user.email_verified do
          true ->
            conn
            |> put_flash(:info, "Your email was confirmed. Please sign in.")
            |> redirect(to: sign_in_path(conn, :new))
          false ->
            # Send confirmation email.
            link = sign_in_url(conn, :confirm_email)
            IO.puts "++++++++++++++++sign in link ++++++++++++++++++++"
            IO.inspect link
            # Send email
            Email.welcome(user, link) |> Mailer.deliver_later
        end
    end
  end
end
