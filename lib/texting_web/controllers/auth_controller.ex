defmodule TextingWeb.AuthController do
  use TextingWeb, :controller
  alias Texting.Account
  alias Texting.Mailer
  alias TextingWeb.Email

  plug Ueberauth

  # OAuth from Google
  # def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do

  #   user_params = %{
  #     token: auth.credentials.token,
  #     email: auth.info.email,
  #     provider: provider,
  #     first_name: auth.info.first_name,
  #     last_name: auth.info.last_name
  #   }
  #   #
  #   # IO.puts("+++++++++++++++++++++++++++++")
  #   # IO.inspect(user_params)
  #   # IO.puts("+++++++++++++++++++++++++++++")

  #   changeset = User.oauth_changeset(%User{}, user_params)

  #   case Account.get_or_insert_user(changeset) do
  #     {:ok, user} ->
  #       conn
  #       |> put_flash(:info, "Welcome!")
  #       |> assign(:current_user, user)
  #       |> put_session(:user_id, user.id)
  #       |> configure_session(renew: true)
  #       |> redirect(to: dashboard_path(conn, :new))

  #     {:error, _reason} ->
  #       conn
  #       |> put_flash(:error, "Error signing in")
  #       |> redirect(to: page_path(conn, :index))
  #   end
  # end

  # def callback(%{assigns: %{useberauth_failure: _fails}} = conn, _params) do
  #   conn
  #   |> put_flash(:error, "Something went wrong.")
  #   |> render(conn, "")
  # end

  # Sign in process using passwordless sign in

  def create(conn, %{"token" => token}) do
    case Account.verify_token(token) do
      {:ok, user_id} ->
        user = Account.get_user_by_id(user_id)

        # Check if user has verified phone number
        check_phone_verified(conn, user)

      {:error, :invalid} ->
        conn
        |> put_flash(:error, "Invalid Link, Can't Log in")
        |> render("new.html")
      {:error, :expired} ->
        conn
        |> put_flash(:error, "Links has been expired. Please do it again")
        |> render("new.html")
    end
  end


  defp check_phone_verified(conn, user) do
    case user.phone_verified do
      true ->
        Account.timestamp_login_time(user)
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome to Dashboard!")
        |> redirect(to: dashboard_path(conn, :new))
      _    ->
        conn
        |> put_flash(:error, "You have to verify your phone number!")
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: phone_verify_path(conn, :new))
    end
  end

  # When a user do "POST" request in sign in via email
  def new(conn, %{"auth" => %{"email" => email}}) do
    case Account.get_user_by_email(email) do
      nil ->
        conn
        |> put_flash(:error, "You have to sign up")
        # Redirect to signup page
        |> redirect(to: sign_up_path(conn, :new))
      user ->
        token = Account.generate_token(user)
        link = sign_in_url(conn, :create, token)
        #TODO: Change to send email.
        IO.puts("+++++++++++++++++++++++")
        IO.puts(link)
        IO.puts("+++++++++++++++++++++++")
        # Send email a link
        Email.sign_in(user, link) |> Mailer.deliver_later
        conn
        |> put_flash(:info, "We sent you One-Time Sign in link by email. Please check your email.")
        |> render(:new)
    end
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: page_path(conn, :index))
  end
end
