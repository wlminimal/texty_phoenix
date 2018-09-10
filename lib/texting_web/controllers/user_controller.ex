defmodule TextingWeb.UserController do
  use TextingWeb, :controller
  alias Texting.Account.User
  alias Texting.Account
  alias Texting.Mailer
  alias TextingWeb.Email

  def new(conn, _params) do
    render(conn, "new.html", changeset: User.changeset(%User{}))
  end

  # User sign up using form
  # def create(conn, %{"register" => params = %{"email" => email}}) do
  #   case Account.get_user_by_email(email) do
  #     nil ->
  #       changeset = User.changeset(%User{}, params)
  #       case changeset.valid? do
  #         true ->
  #           case Account.insert_user(changeset) do
  #             {:ok, user} ->
  #               IO.inspect user

  #               # Create confirmation email link

  #               # forward to phone verification page
  #               conn
  #               |> put_session(:user_id, user.id)
  #               |> configure_session(renew: true)
  #               |> redirect(to: phone_verify_path(conn, :new))
  #             {:error, _} ->
  #               conn
  #               |> put_flash(:error, "Can't sign up, try again!")
  #               |> render(:new, changeset: changeset)
  #           end
  #         _ ->
  #           conn
  #             |> put_flash(:error, "Oops Something wrong! Try Again!")
  #             |> render(:new,  changeset: changeset)
  #       end

  #     user ->
  #       conn
  #       |> put_flash(:error, "You are already registered with this email. Please sign in")
  #       |> redirect(to: sign_in_path(conn, :new))
  #   end
  # end

  def create(conn, %{"register" => params = %{"email" => email}}) do
    case Account.get_user_by_email(email) do
      nil ->
        changeset = User.changeset(%User{}, params)
        case changeset.valid? do
          true ->
            case Account.insert_user(changeset) do
              {:ok, user} ->
                IO.inspect user
                # Create confirmation email link
                token = Account.generate_token(user)
                link = phone_verify_url(conn, :new, token)

                # Send email
                welcome(user, link)

                conn
                |> put_session(:user_id, user.id)
                |> put_flash(:info, "Check your inbox for a confirmation email.")
                |> redirect(to: sign_up_path(conn, :new))
              {:error, _} ->
                conn
                |> put_flash(:error, "Can't sign up, try again!")
                |> render(:new, changeset: changeset)
            end
          _ ->
            conn
              |> put_flash(:error, "Oops Something wrong! Try Again!")
              |> render(:new,  changeset: changeset)
        end

      _user ->
        conn
        |> put_flash(:error, "You are already registered with this email. Please sign in")
        |> redirect(to: sign_in_path(conn, :new))
    end
  end

  defp welcome(user, link) do
    Email.welcome(user, link) |> Mailer.deliver_later
  end
end
