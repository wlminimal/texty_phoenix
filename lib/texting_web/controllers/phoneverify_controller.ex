defmodule TextingWeb.PhoneVerifyController do
	use TextingWeb, :controller
	alias Texting.PhoneVerify
	alias Texting.Formatter
	alias Texting.Account

	# def new(conn, %{"token" => token}) do

	# 	case Account.verify_token(token) do
	# 		{:ok, user_id} ->


	# 			user =  Account.get_user_by_id(user_id)
	# 			changeset = Account.change_user(user, %{email_verified: true})

	# 			case  Account.update_user(changeset) do
	# 				user ->
	# 					conn
	# 					|> put_session(:user_id, user.id)
	# 					|> render("new.html", conn: conn)
	# 				_ ->
	# 					conn
	# 					|> put_flash(:error, "Something wrong try again please.")
	# 					|> redirect(to: sign_up_path(conn, :new))
	# 			end


  #     {:error, :invalid} ->
  #       conn
  #       |> put_flash(:error, "Invalid Link, Can't Log in")
  #       |> redirect(to: sign_in_path(conn, :new))
  #     {:error, :expired} ->
  #       conn
  #       |> put_flash(:error, "Links has been expired. Please do it again")
  #       |> redirect(to: sign_in_path(conn, :new))
  #   end
	# end

	def new(conn, _params) do
		case get_session(conn, :user_id) do
			{:error, _}     ->
				conn
				|> redirect(to: sign_in_path(conn, :new))
				|> halt()
			user_id ->
				render(conn, "new.html", conn: conn)
		end
	end


	def create(conn, %{"phone_verify" => %{"phone_number" => phone_number}}) do
		phone_number = Formatter.phone_number_formatter_without_one(phone_number)

		case PhoneVerify.phone_verify_start(phone_number) do
			{:ok, message} ->
				conn
				|> put_flash(:info, message)
				|> put_session(:phone_number, phone_number)
				|> redirect(to: code_verify_path(conn, :new))
			{:error, reason} ->
				conn
				|> put_flash(:error, reason)
				|> render("new.html")
		end
	end
end
