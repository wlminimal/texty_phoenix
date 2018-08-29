defmodule TextingWeb.Dashboard.InvoiceController do
  use TextingWeb, :controller
  alias Texting.Finance

  def new(conn, params) do
    user = conn.assigns.current_user
    invoices = Finance.list_invoices(user.id, params)
    IO.puts "+++++++++++ Invoices +++++++++++++"
    IO.inspect invoices
    IO.puts "+++++++++++ Invoices +++++++++++++"
    charge_history = Finance.list_charge_history(user.id, params)
    upcoming_invoice = Finance.upcoming_invoice(user.stripe.customer_id)
    render conn, "new.html", invoices: invoices, charge_history: charge_history,
                             next_billing_date: upcoming_invoice.period_end,
                             amount_due: upcoming_invoice.total
  end
end
