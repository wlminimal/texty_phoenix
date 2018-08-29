defmodule TextingWeb.Dashboard.BillingInfoController do
  use TextingWeb, :controller
  alias Texting.Finance

  def new(conn, _params) do
    user = conn.assigns.current_user
    stripe_customer = Finance.get_customer(user.stripe.customer_id)
    stripe_key = System.get_env("STRIPE_PUBLIC_KEY")
    case Finance.customer_has_card?(stripe_customer) do
      {:has_card, true} ->
        {default_card_id, cards} = Finance.get_card_info(stripe_customer)
        render conn, "new.html", cards: cards,
                                 has_card: true,
                                 stripe_key: stripe_key,
                                 default_card_id: default_card_id
      {:no_card, false} ->
        render conn, "new.html", has_card: false, stripe_key: stripe_key
    end
  end

  @doc """
  Add credit card
  """
  def create(conn, %{"stripeToken" => token}) do
    user = conn.assigns.current_user
    case Finance.add_card(user.stripe.customer_id, token) do
      {:ok, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: billing_info_path(conn, :new))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: billing_info_path(conn, :new))
    end
  end

  def delete_card(conn, %{"id" => card_id}) do
    user = conn.assigns.current_user
    case Finance.delete_card(card_id, user.stripe.customer_id) do
      {:ok, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: billing_info_path(conn, :new))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: billing_info_path(conn, :new))
    end
  end

  def make_default_card(conn, %{"id" => card_id}) do
    user = conn.assigns.current_user
    case Finance.update_customer(user.stripe.customer_id, %{default_source: card_id}) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Your default card is updated.")
        |> redirect(to: billing_info_path(conn, :new))
      {:error, _} ->
        conn
        |> put_flash(:error, "Can't make it default. Please try again later.")
        |> redirect(to: billing_info_path(conn, :new))
    end
  end
end
