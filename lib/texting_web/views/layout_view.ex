defmodule TextingWeb.Layout.PageTitle do
  alias TextingWeb.Dashboard.{DashboardView,
                              SmsView,
                              MmsView,
                              PhonebookView,
                              CampaignHistoryView,
                              AnalyticsView,
                              BillingInfoView,
                              InvoiceView,
                              PersonView,
                              RecipientView,
                              CheckoutSmsView,
                              CheckoutSmsPreviewView,
                              CheckoutMmsView,
                              CheckoutMmsPreviewView,
                              BuyCreditView,
                              UploadContactView,
                              PlanView,
                              AccountInfoView,
                              PaymentView,
                              CampaignView,
                              ContactUsView}

  alias TextingWeb.Dashboard.Admin.{CustomerView}
  @app_name "Texty"


  def for({view, action, assigns}) do
    {view, action, assigns}
    |> get()
    |> add_app_name()
  end

  defp get({DashboardView, :new, _}) do
    "Dashboard"
  end

  defp get({SmsView, :index, _}) do
    "Text Campaign"
  end

  defp get({MmsView, :index, _}) do
    "Image Campaign"
  end

  defp get({PhonebookView, :index, _}) do
    "Phonebooks"
  end

  defp get({PhonebookView, :edit, _}) do
    "Phonebooks - Edit"
  end

  defp get({PhonebookView, :new, _}) do
    "Phonebooks - New"
  end

  defp get({PhonebookView, :show, _}) do
    "Phonebooks"
  end

  defp get({PhonebookView, :create, _}) do
    "Phonebooks"
  end

  defp get({PhonebookView, :update, _}) do
    "Phonebooks"
  end

  defp get({PhonebookView, :delete, _}) do
    "Phonebooks"
  end

  defp get({CampaignHistoryView, :index, _}) do
    "Campaign History"
  end

  defp get({CampaignHistoryView, :show, _}) do
    "Campaign History - Details"
  end

  defp get({AnalyticsView, :index, _}) do
    "Analytics"
  end

  defp get({BillingInfoView, :new, _}) do
    "Billing Information"
  end

  defp get({BillingInfoView, :create, _}) do
    "Billing Information"
  end

  defp get({InvoiceView, :new, _}) do
    "Invoices"
  end

  defp get({PersonView, :new, _}) do
    "Contact"
  end

  defp get({PersonView, :edit, _}) do
    "Contact"
  end

  defp get({PersonView, :show, _}) do
    "Contact"
  end

  defp get({PersonView, :create, _}) do
    "Contact"
  end

  defp get({PersonView, :update, _}) do
    "Contact"
  end

  defp get({PersonView, :delete, _}) do
    "Contact"
  end

  defp get({RecipientView, :show, _}) do
    "Recipients"
  end

  defp get({CheckoutSmsView, :show_sms, _}) do
    "Send Text Message"
  end

  defp get({CheckoutSmsView, :preview_sms, _}) do
    "Send Text Message"
  end

  defp get({CheckoutSmsView, :create_short_link, _}) do
    "Send Text Message"
  end

  defp get({CheckoutSmsPreviewView, :index, _}) do
    "Send Text Message - Preview"
  end

  defp get({CheckoutSmsPreviewView, :send_sms, _}) do
    "Send Text Message"
  end

  defp get({CheckoutMmsView, :show_mms, _}) do
    "Send Image Message"
  end

  defp get({CheckoutMmsView, :preview_mms, _}) do
    "Send Image Message"
  end

  defp get({CheckoutMmsPreviewView, :index, _}) do
    "Send Image Message - Preview"
  end

  defp get({CheckoutMmsPreviewView, :send_mms, _}) do
    "Send Image Message"
  end

  defp get({BuyCreditView, :new, _}) do
    "Buy Credit"
  end

  defp get({BuyCreditView, :create, _}) do
    "Buy Credit"
  end

  defp get({UploadContactView, :new, _}) do
    "Upload Contact"
  end

  defp get({UploadContactView, :upload, _}) do
    "Upload Contact"
  end

  defp get({PlanView, :new, _}) do
    "Plan"
  end

  defp get({PlanView, :create, _}) do
    "Plan"
  end

  defp get({AccountInfoView, :index, _}) do
    "Account Information"
  end

  defp get({AccountInfoView, :edit, _}) do
    "Edit Account Information"
  end

  defp get({PaymentView, :new, _}) do
    "Payment Info"
  end

  defp get({PaymentView, :create, _}) do
    "Payment Info"
  end

  defp get({CampaignView, :index, _}) do
    "Start a Campaign"
  end

  defp get({ContactUsView, :index, _}) do
    "Contact Us"
  end

  defp get({CustomerView, :index, _}) do
    "Admin - Customer List"
  end

  defp get({CustomerView, :show, _}) do
    "Admin - Customer Detail"
  end



  defp get(_), do: nil

  defp add_app_name(nil), do: @app_name
  defp add_app_name(title), do: "#{title}"
end

defmodule TextingWeb.LayoutView do
  use TextingWeb, :view
  import TextingWeb.Dashboard.RecipientView, only: [recipient_count: 1]
  alias TextingWeb.Layout.PageTitle

  def page_title(conn) do
    view = view_module(conn)
    action = action_name(conn)
    PageTitle.for({view, action, conn.assigns})
  end

  def switch_locale_path(_conn, locale, language) do
    "<a href=\"?locale=#{locale}\">#{language}</a>" |> Phoenix.HTML.raw()
  end
end
