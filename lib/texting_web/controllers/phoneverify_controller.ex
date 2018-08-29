defmodule TextingWeb.PhoneVerifyController do
	use TextingWeb, :controller
	alias Texting.PhoneVerify

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
