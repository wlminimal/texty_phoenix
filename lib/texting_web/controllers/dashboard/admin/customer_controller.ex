defmodule TextingWeb.Dashboard.Admin.CustomerController do
  use TextingWeb, :controller
  alias Texting.{Admin, Account, Finance, Contact, Sales}

  def index(conn, params) do
    users = Admin.get_all_user(params)
    render conn, "index.html", customers: users
  end

  def show(conn, %{"id" => id} = params) do
    user = Account.get_user_by_id(id)
    stripe_customer = Finance.get_customer(user.stripe.customer_id)
    invoices = Finance.list_invoices(user.id, params)
    charge_history = Finance.list_charge_history(user.id, params)
    #upcoming_invoice = Finance.upcoming_invoice(user.stripe.customer_id)
    phonebook_count = Contact.list_phonebooks(user.id) |> Enum.count
    contact_count = Contact.get_all_people_count(user.id)
    campaigns_history = Sales.get_all_confirmed_status_order_with_pagination(user.id, params)

    case Finance.customer_has_card?(stripe_customer) do
      {:has_card, true} ->
        {default_card_id, cards} = Finance.get_card_info(stripe_customer)
        render conn, "show.html",
          customer: user,
          cards: cards,
          default_card_id: default_card_id,
          has_card: true,
          invoices: invoices,
          charge_history: charge_history,
          # next_billing_date: upcoming_invoice.period_end,
          # amount_due: upcoming_invoice.total,
          phonebook_count: phonebook_count,
          contact_count: contact_count,
          campaigns_history: campaigns_history
      {:no_card, false} ->
        render conn, "show.html",
          customer: user,
          has_card: false,
          invoices: invoices,
          charge_history: charge_history,
          # next_billing_date: upcoming_invoice.period_end,
          # amount_due: upcoming_invoice.total,
          phonebook_count: phonebook_count,
          contact_count: contact_count,
          campaigns_history: campaigns_history
    end

  end

  def edit(conn, %{"id" => id}) do
    user = Account.get_user_by_id(id)
    changeset = Account.change_user(user)

    render conn, "edit.html", customer: user, changeset: changeset
  end

  def update(conn, %{"admin" => params}) do
    user = conn.assigns.current_user
    %{"credits" => credit, "email" => email,
      "first_name" => first_name,
      "last_name" => last_name,
      "phone_number" => phone_number} = params
    user_changeset = Account.change_user(user, %{first_name: first_name,
                                                 last_name: last_name,
                                                 email: email,
                                                 phone_number: phone_number,
                                                 credits: credit})
    Account.update_user(user_changeset)
    conn
    |> redirect(to: customer_path(conn, :index))
  end
end
