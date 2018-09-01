defmodule Texting.Finance do
  alias Payment
  alias Texting.Account
  alias Texting.Finance.{Stripe, Invoice, Charge}
  alias Texting.Repo
  alias Texting.Formatter
  import Ecto.Query
  import Ecto


  #####################################################################
  # Stripe Struct
  #####################################################################

  def create_stripe(user, attrs \\ %{}) do
    build_assoc(user, :stripe)
    |> Stripe.changeset(attrs)
    #|> Repo.insert()
  end

  def insert_stripe(changeset) do
    changeset
    |> Repo.insert()
  end

  def update_stripe(changeset) do
    changeset
    |> Repo.update!()
  end

  def get_stripe(user) do
    Repo.get_by(Stripe, user_id: user.id)
  end

  def get_stripe_by_subs_id(subs_id) do
    query = from s in Stripe, where: s.subscription_id == ^subs_id
    Repo.one!(query)
  end

  def get_stripe_by_user_id(user_id) do
    query = from s in Stripe, where: s.user_id == ^user_id
    Repo.one(query)
  end

  def get_stripe_by_stripe_id(stripe_id) do
    query = from s in Stripe, where: s.customer_id == ^stripe_id
    Repo.one(query)
  end

  def change_stripe(%Stripe{} = stripe) do
    Stripe.changeset(stripe, %{})
  end

  def change_stripe(%Stripe{} = stripe, attrs \\ %{}) do
    Stripe.changeset(stripe, attrs)
  end



  def create_stripe_customer_and_subscribe_to_plan(user) do
    email = user.email
    {:ok, %{id: stripe_id} } = Payment.create_customer(%{"email" => email, "description" => email})
    free_plan_id = System.get_env("FREE_PLAN_ID")

    {:ok, %{id: subscription_id}} = Payment.create_subscription(%{customer: stripe_id, plan: free_plan_id})
    {stripe_id, "Free", free_plan_id, subscription_id}

  end



  #####################################################################
  # Charge..
  #####################################################################

  def create_charge(amount, source, description) do
    Payment.create_charge(%{"amount" => amount,
                            "customer" => source,
                            "description" => description,
                            "currency" => "usd"})
  end

  @doc """
  Create charge struct and save it to the database.
  Retrieving data from database is faster than requesting from stripe api
  'charge' is charge struct from create_charge function
  """
  def create_charge_struct(charge) do
    %{amount: amount, id: charge_id, source: %{customer: stripe_id, last4: card_last4}, created: date, description: description} = charge
    date = Formatter.unix_time_to_normal_time(date)
    user_stripe = get_stripe_by_stripe_id(stripe_id)
    Charge.changeset(%Charge{}, %{charge_id: charge_id,
                                  amount: amount,
                                  stripe_id: stripe_id,
                                  card: card_last4,
                                  date: date,
                                  description: description,
                                  user_id: user_stripe.user_id})
    |> Repo.insert!
  end

  def list_charge_history(user_id, params) do
    query = from c in Charge, where: c.user_id == ^user_id, order_by: [desc: c.date]
    Repo.paginate(query, params)
  end

  #####################################################################
  # Stripe Customer
  #####################################################################

  def get_customer(stripe_id), do: Payment.retrieve_customer(stripe_id)
  def update_customer(stripe_id, changes), do: Payment.update_customer(stripe_id, changes)
  def customer_has_card?(stripe_customer), do: Payment.customer_has_card?(stripe_customer)



  #####################################################################
  # Card info..
  #####################################################################
  def get_card_info(stripe_customer) do
    %{default_source: default_card_id, sources: %{data: cards}} = stripe_customer
    {default_card_id, cards}
  end

  def add_card(stripe_id, token) do
    Payment.create_card(stripe_id, token)
  end

  def delete_card(card_id, stripe_id) do
    Payment.delete_card(card_id, stripe_id)
  end

  #####################################################################
  # Invoice
  #####################################################################

  @spec list_invoices(any(), keyword() | map()) :: Scrivener.Page.t()
  def list_invoices(user_id, params) do
    query = from i in Invoice, where: i.user_id == ^user_id, order_by: [desc: i.date]
    Repo.paginate(query, params)
  end

  @doc """
  invoice_data is event data from Stripe
  #TODO: Turn on Ultrahook...
  """
  def create_invoice(invoice_data) do
    %{"data" => %{"object" => %{"customer" => stripe_id, "number" => receipt_number, "lines" => %{"data" => [%{"amount" => amount, "description" => description, "id" => invoice_id, "type" => type, "period" => %{"end" => _end, "start" => date}}]}}}} = invoice_data
    user_stripe = get_stripe_by_stripe_id(stripe_id)
    date = Formatter.unix_time_to_normal_time(date)

    Invoice.changeset(%Invoice{}, %{invoice_id: invoice_id, amount: amount, description: description, type: type, date: date, user_id: user_stripe.user_id, receipt_number: receipt_number})
    |> Repo.insert!

  end
  @doc """
  return {:ok, %Stripe.Invoice{}}
  %Stripe.Invoice{next_payment_attempt is next billing date}
  """
  def upcoming_invoice(stripe_id) do
    case Payment.upcoming_invoice(stripe_id) do
      {:ok, upcoming_invoice} -> {:ok, upcoming_invoice}
      {:error, reason} -> {:error, reason}
    end
  end

  #####################################################################
  # Subscription
  #####################################################################

  def update_subscription(subscription_id, plan_id) do
    Payment.update_subscription(subscription_id, %{"plan" => plan_id})
  end


  def cancel_subscription(subscription_id) do
    Payment.cancel_subscription(subscription_id, %{at_period_end: true})
  end

  def get_subscription_id(user) do
    %{subscription_id: id} = get_stripe(user)
    id
  end

  @doc """
  Update Subscription in Stripe
  If succeeds return Stripe.Plan for saving detail to user database
  or Return {:error, message}
  """
  def change_plan(subscription_id, plan_id) do
    # update subscription
    case update_subscription(subscription_id, plan_id) do
      {:ok, subscription} ->
        %{ plan: plan } = subscription
        { :ok, plan }
      {:error, _} ->
        { :error, "Please enter your payment information." }
    end
  end

  def get_plan_by_id(plan_id) do
    Payment.get_plan_by_id(plan_id)
  end

  def get_users_plan(user_id) do
    %{plan_id: plan_id} = Account.get_user_by_id(user_id)
    get_plan_by_id(plan_id)
  end

  def user_is_free_plan?(user) do
    if user.stripe.plan_name == "Free" do
      {:free_plan, true}
    else
      {:paid_plan, false}
    end
  end

end
