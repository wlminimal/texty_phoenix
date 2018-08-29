defmodule TextingWeb.CodeVerifyController do
  use TextingWeb, :controller
  alias Texting.PhoneVerify
  alias Texting.Account
  alias Texting.Finance
  alias Texting.Messenger
  alias Texting.Formatter
  alias Ecto.Multi
  alias Texting.Repo


  def new(conn, _params) do
    phone_number = get_session(conn, :phone_number)
    render(conn, "new.html", phone_number: phone_number )
  end

  def create(conn, %{"verify_check_code" => %{"code_number" => code_number}}) do
    phone_number = get_session(conn, :phone_number)
    IO.puts "+++++++++++++++++++++++++++++++++++++++++++++"
    IO.inspect code_number
    IO.inspect phone_number
    IO.puts "+++++++++++++++++++++++++++++++++++++++++++++"

    case PhoneVerify.phone_verify_check(phone_number, code_number) do
      {:ok, message} ->

        IO.puts "++++++++++ message _++++++++++++++++++"
        IO.inspect message
        IO.puts "++++++++++ message _++++++++++++++++++"
        # Save phone number to database
        case Account.get_user_from_assigns(conn) do
          user ->
            # change phone number format to 1 222 333 4444
            new_phone_number = Formatter.phone_number_formatter(phone_number)
            # User changeset
            user_changeset = Account.change_user(user, %{phone_number: new_phone_number, phone_verified: true, credits: 100})

            # Twilio
            {account, token, msid} = Messenger.set_free_account_info_to_user()
            twilio_changeset = Messenger.create_twilio(user, %{account: account, token: token, msid: msid, available_phone_number_count: 0})

            # Stripe
            {stripe_id, plan_name, plan_id, subscription_id} = Finance.create_stripe_customer_and_subscribe_to_plan(user)
            stripe_changeset = Finance.create_stripe(user, %{customer_id: stripe_id, subscription_id: subscription_id, plan_id: plan_id, plan_name: plan_name})

            case update_user_twilio_stripe_account(user_changeset, twilio_changeset, stripe_changeset) do
              {:ok, %{user: _user, twilio: _twilio, stripe: _stripe}} ->
                conn
                |> delete_session(:phone_number)
                |> put_flash(:info, message)
                |> redirect(to: dashboard_path(conn, :new))
              {:error, :user, _failed_value, _changes_successful} ->
                conn
                |> delete_session(:phone_number)
                |> put_flash(:error, "Something Wrong. Try Again!")
                |> redirect(to: sign_in_path(conn, :new))
              {:error, :twilio, _failed_value, _changes_successful} ->
                conn
                |> delete_session(:phone_number)
                |> put_flash(:error, "Something Wrong. Try Again!")
                |> redirect(to: sign_in_path(conn, :new))
              {:error, :stripe, _failed_value, _changes_successful} ->
                conn
                |> delete_session(:phone_number)
                |> put_flash(:error, "Something Wrong. Try Again!")
                |> redirect(to: sign_in_path(conn, :new))
            end
            conn
            |> delete_session(:phone_number)
            |> put_flash(:info, message)
            |> redirect(to: dashboard_path(conn, :new))
          nil ->
            conn
            |> delete_session(:phone_number)
            |> put_flash(:error, "Something Wrong. Try Again!")
            |> redirect(to: sign_in_path(conn, :new))
        end
      {:error, reason} ->
        IO.puts "++++++++++ Erorr _++++++++++++++++++"
        IO.inspect reason
        IO.puts "++++++++++ Erorr _++++++++++++++++++"
        conn
        |> put_flash(:error, reason)
        |> render("new.html")
    end
  end

  defp update_user_twilio_stripe_account(user_changeset, twilio_changeset, stripe_changeset) do
    Multi.new
    |> Multi.update(:user,  user_changeset)
    |> Multi.insert(:twilio, twilio_changeset)
    |> Multi.insert(:stripe, stripe_changeset)
    |> Repo.transaction()
  end
end
