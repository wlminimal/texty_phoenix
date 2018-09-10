defmodule TextingWeb.Email do
  use Bamboo.Phoenix, view: TextingWeb.EmailView

  # When user first sign up
  def welcome(user, link) do
    gatebot_email()
    |> to(user)
    |> subject("Verify Your Email Address")
    |> assign(:user, user)
    |> assign(:link, link)
    |> render(:welcome)
  end

  # When user sign in via email or OAuth
  def sign_in(user, link) do
    gatebot_email()
    |> to(user.email)
    |> subject("Texty - Sign In Link")
    |> assign(:user, user)
    |> assign(:link, link)
    |> render(:sign_in)
  end

  def contact_us_email(from_email, name, message) do
    new_email()
    |> from(from_email)
    |> to("info@texty.marketing")
    |> subject("Email from Customer")
    |> assign(:name, name)
    |> assign(:from_email, from_email)
    |> assign(:message, message)
    |> put_html_layout({TextingWeb.LayoutView, "email_gatebot.html"})
    |> render(:contact_us)
  end

  def new_customer(customer_name) do
    gatebot_email()
    |> to("info@texty.marketing")
    |> subject("New customer signs up")
    |> assign(:customer_name, customer_name)
    |> render(:new_customer)
  end

  defp gatebot_email() do
    new_email()
    |> from("info@texty.marketing")
    |> put_header("Reply-To", "info@texty.marketing")
    |> put_html_layout({TextingWeb.LayoutView, "email_gatebot.html"})
  end
end

defimpl Bamboo.Formatter, for: Texting.Account.User do
  def format_email_address(user, _opts) do
    { user.first_name, user.email }
  end
end
