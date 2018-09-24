defmodule TextingWeb.Router do
  use TextingWeb, :router

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard do
    plug TextingWeb.Plugs.LoadUser
    plug TextingWeb.Plugs.DashboardLayout
    plug TextingWeb.Plugs.FetchRecipients
  end

  pipeline :help do
    plug TextingWeb.Plugs.HelpLayout
  end

  pipeline :loaduser do
    plug TextingWeb.Plugs.LoadUser
  end

  pipeline :admin do
    plug TextingWeb.Plugs.AuthorizeAdmin
  end

  scope "/dashboard/admin", TextingWeb.Dashboard.Admin do
    pipe_through [:browser, :dashboard, :admin]

    get "/customers", CustomerController, :index
    get "/customers/:id", CustomerController, :show
    get "/customers/:id/edit", CustomerController, :edit
    put "/customers/:id/edit", CustomerController, :update
    get "/customers/campaign/:id", CampaignAdminController, :index
  end

  scope "/", TextingWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/", PageController, :create
    get "/privacy-policy", PrivacyController, :index
    get "/terms-conditions", TermsController, :index

    # Sign in and out
    get "/sign-in", AuthController, :new, as: :sign_in
    get "/sign-in/confirm-email/", AuthController, :confirm_email, as: :sign_in
    post "/sign-in", AuthController, :new, as: :sign_in
    get "/sign-out", AuthController, :delete, as: :sign_out
    get "/sign-in/:token", AuthController, :create, as: :sign_in
    get "/sign-up", UserController, :new,  as: :sign_up
    post "/sign-up", UserController, :create, as: :sign_up

    get "/confirm-email", ConfirmEmailController, :new
    post "/confirm-email", ConfirmEmailController, :create

  end

     # Tutorial and Help
  scope "/help", TextingWeb.Help do
    pipe_through [:browser, :help]
    get "/", HelpController, :index
    get "/how-to-start-a-campaign", StartCampaignController, :index
    get "/how-to-upload-contact", UploadContactController, :index
  end

  scope "/", TextingWeb do
    pipe_through [:browser, :loaduser]

    get "/phoneverify", PhoneVerifyController, :new
    post "/phoneverify", PhoneVerifyController, :create
    get "/codeverify", CodeVerifyController, :new
    post "/codeverify", CodeVerifyController, :create
  end

  scope "/dashboard", TextingWeb.Dashboard do
    pipe_through [:browser, :dashboard]

    get "/campaign", CampaignController, :index

    get "/contact", ContactUsController, :index
    post "/contact", ContactUsController, :create

    get "/", DashboardController, :new

    post "/add-to-recipients", RecipientController, :add
    get "/recipients/", RecipientController, :show
    delete "/recipients/:id", RecipientController, :delete
    post "/recipients/delete", RecipientController, :delete_selected


    get "/checkout/sms", CheckoutSmsController, :show_sms
    put "/checkout/sms", CheckoutSmsController, :preview_sms
    post "/checkout/sms/shorten", CheckoutSmsController, :create_short_link

    #put "/checkout/sms/confirm", CheckoutSmsController, :confirm_sms
    get "/checkout/sms/preview", CheckoutSmsPreviewController, :index
    post "/checkout/sms/preview", CheckoutSmsPreviewController, :send_sms

    get "/checkout/mms", CheckoutMmsController, :show_mms
    post "/checkout/mms", CheckoutMmsController, :preview_mms
    get "/checkout/mms/preview", CheckoutMmsPreviewController, :index
    #put "/checkout/mms/confirm", CheckoutMmsController, :confirm_mms
    post "/checkout/mms/preview", CheckoutMmsPreviewController, :send_mms

    get "/campaign/history", CampaignHistoryController, :index
    get "/campaign/history/:id", CampaignHistoryController, :show

    get "/buy-credit", BuyCreditController, :new
    post "/buy-credit", BuyCreditController, :create

    get "/payment", PaymentController, :new
    post "/payment", PaymentController, :create

    get "/plan", PlanController, :new
    post "/plan", PlanController, :create
    post "/plan/cancel", PlanController, :delete

    get "/upload-contact", UploadContactController, :new
    post "/upload-contact", UploadContactController, :upload

    get "/billing", BillingInfoController, :new
    post "/billing", BillingInfoController, :create
    delete "/billing/:id", BillingInfoController, :delete_card
    post "/billing/change/default-card/:id", BillingInfoController, :make_default_card

    get "/invoice", InvoiceController, :new

    get "/analytics", AnalyticsController, :index

    get "/phonenumbers", PhonenumberController, :new

    get "/account-info", AccountInfoController, :index
    get "/account-info/:id", AccountInfoController, :edit
    put "/account-info", AccountInfoController, :update

    get "/account-info-welcome-message", AccountInfoController, :new_welcome_message
    post "/account-info-welcome-message", AccountInfoController, :create_welcome_message
    get "/account-info-welcome-message/edit", AccountInfoController, :edit_welcome_message
    put "/account-info-welcome-message", AccountInfoController, :update_welcome_message


    resources "/phonebooks", PhonebookController do
      resources "/people", PersonController, except: [:index]
    end

    # CSV Export
    get "/csv/:id", CsvExportController, :export



  end

  # scope "/auth", TextingWeb do
  #   pipe_through :browser

  #   get "/:provider", AuthController, :request
  #   get "/:provider/callback", AuthController, :callback
  #   post "/:provider/callback", AuthController, :callback
  # end

  #Other scopes may use custom stacks.
  scope "/api", TextingWeb do
    pipe_through :api

    # Stripe Webhook
   # post "/planchanged", StripeWebhookController, :handle_invoiceitem_created
   # post "/subscription-canceled", StripeWebhookController, :handle_subscription_deleted
    post "/invoice-payment-succeeded", StripeWebhookController, :handle_invoice_payment_succeeded
    # post "/charge-succeeded", StripeWebhookController, :handle_charge_succeeded

    # Twilio Webhook
    post "/message-incoming", TwilioWebhookController, :message_incoming
    post "/message-status", TwilioWebhookController, :message_status
  end
end
