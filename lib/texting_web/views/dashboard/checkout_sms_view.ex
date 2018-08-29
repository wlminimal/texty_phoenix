defmodule TextingWeb.Dashboard.CheckoutSmsView do
  use TextingWeb, :view

  def total_sms_price(recipients_count) do
    sms_credit = System.get_env("SMS_CREDIT_UNIT")
    {sms_credit, _} = Integer.parse sms_credit
    total_price = sms_credit * recipients_count
    total_price
  end
end
