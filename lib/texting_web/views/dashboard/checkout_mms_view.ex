defmodule TextingWeb.Dashboard.CheckoutMmsView do
  use TextingWeb, :view

  def total_mms_price(recipients_count) do
    mms_credit = System.get_env("MMS_CREDIT_UNIT")
    {mms_credit, _} = Integer.parse mms_credit
    total_price = mms_credit * recipients_count
    total_price
  end
end
