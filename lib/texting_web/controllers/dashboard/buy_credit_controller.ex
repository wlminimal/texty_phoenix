defmodule TextingWeb.Dashboard.BuyCreditController do
  use TextingWeb, :controller
  alias Texting.Finance
  alias Texting.Account
  alias Texting.Credit
  alias Texting.Formatter

  def new(conn, _params) do
    stripe_key = System.get_env("STRIPE_PUBLIC_KEY")
    render conn, "new.html", stripe_key: stripe_key
  end

  @doc """
  if user has card info, Create a charge of selected amount.
  or
  redirect to payment page to get a user's card information..
  """
  def create(conn, %{"amount" => amount}) do
    user = conn.assigns.current_user
    stripe_customer = Finance.get_customer(user.stripe.customer_id)
    correct_format_amount = Formatter.stripe_money_to_currency(amount)
    with {:paid_plan, false} <- Finance.user_is_free_plan?(user),
         {:has_card, true} <- Finance.customer_has_card?(stripe_customer) do

      case Finance.create_charge(amount, user.stripe.customer_id, "Charging #{correct_format_amount}") do
        {:ok, charge} ->
          Finance.create_charge_struct(charge)
          user
          |> Account.change_user
          |> Credit.add_credit(amount)
          |> Account.update_user
          conn
          |> put_flash(:info, "Charging is successful.")
          |> redirect(to: dashboard_path(conn, :new))
        {:error, _error} ->
          conn
          |> put_flash(:error, "Something went wrong!")
          |> redirect(to: buy_credit_path(conn, :new))
      end
    else
      # When user tries to charge as a free planner. redirect plan page
      {:free_plan, true} ->
        conn
        |> put_flash(:info, "You must upgrade a plan first.")
        |> redirect(to: plan_path(conn, :new))
      # When user has no card info, redirect to payment page
      {:no_card, false} ->
        conn
        |> put_session(:amount_to_pay, amount)
        |> put_session(:amount_description, "Charging $#{correct_format_amount}")
        |> put_flash(:info, "We need your card information")
        |> redirect(to: payment_path(conn, :new))
    end
  end

  def create(conn, _) do
    conn
    |> put_flash(:error, "Something went wrong!")
    |> redirect(to: buy_credit_path(conn, :new))
  end
end
