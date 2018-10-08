defmodule TextingWeb.Dashboard.PaymentController do
  use TextingWeb, :controller
  alias Texting.Finance
  alias Texting.Credit
  alias Texting.Account

  def new(conn, _params) do
    stripe_key = System.get_env("STRIPE_PUBLIC_KEY")
    render conn, "new.html", stripe_key: stripe_key
  end

  # Create a charge
@doc """
Collecting Card information.
This page will be hit by who has no card information.
"""
  def create(conn, %{"stripeToken" => token}) do
    user = conn.assigns.current_user
    Finance.update_customer(user.stripe.customer_id, %{"source" => token, "email" => user.email, "description" => user.email})
    case get_session(conn, :redirect_from_plan_page) do
      true ->
        conn
        |> put_flash(:info, "We got your card information!, Now choose your plan.")
        |> delete_session(:redirect_from_plan_page)
        |> redirect(to: plan_path(conn, :index))
      nil ->
        amount = get_session(conn, :amount_to_pay)
        description = get_session(conn, :amount_description)
        # Charge,
        case Finance.create_charge(amount, user.stripe.customer_id, description) do
          {:ok, charge} ->
            Finance.create_charge_struct(charge)
            # Add credit
            user
            |> Account.change_user
            |> Credit.add_credit(amount)
            |> Account.update_user

            conn
            |> delete_session(:amount_to_pay)
            |> delete_session(:amount_description)
            |> put_flash(:info, "New credits added to your account successfully!")
            |> redirect(to: dashboard_path(conn, :new))
          {:error, _error} ->
            conn
            |> delete_session(:buy_credit_amount)
            |> put_flash(:error, "Can't buy credit, Please check card information.")
            |> redirect(to: buy_credit_path(conn, :index))
        end
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "Sometshing went wrong!")
    |> redirect(to: buy_credit_path(conn, :index))
  end
end
