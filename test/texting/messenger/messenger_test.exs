defmodule Texting.MessengerTest do
  use Texting.DataCase

  alias TextingWeb.Fixture
  alias Texting.Messenger
  alias Texting.Sms

  @to_number ["2135055819"]
  @from_number "5005550006"
  @body "Hello"
  @status_callback System.get_env("MESSAGE_STATUS_CALLBACK")
  @account System.get_env("TWILIO_TEST_ACCOUNT_SID")
  @token System.get_env("TWILIO_TEST_AUTH_TOKEN")


  test "create_message_status_with_sms_with_number" do
    result = Sms.send_sms_using_from_number(
      @to_number,
      @body,
      @from_number,
      @status_callback,
      @account ,
      @token
      )
    assert [ok: %ExTwilio.Message{}] == result
  end

  test "extracting_message_correctly" do
    user = Fixture.user_fixture(%{})
    order = Fixture.order_fixture(%{})

    result = Sms.send_sms_using_from_number(
      @to_number,
      @body,
      @from_number,
      @status_callback,
      @account ,
      @token
      )
  end
end
