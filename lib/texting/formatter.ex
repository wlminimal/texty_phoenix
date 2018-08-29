defmodule Texting.Formatter do
  alias Timex

  @doc """
  Convert user's phone number to correct format
  ex) 12345678911
  used in /dashboard/sms
  return phonenumber as list to send sms
  """
  @spec phone_number_to_list(String.t) :: list
  def phone_number_to_list(phone_numbers) do
    phone_numbers
    |> String.split([",", "."])
    |> Enum.map(fn n -> String.replace(n, [" ", "-", "(", ")", "="], "") end)
    |> Enum.map(fn n -> "1" <> n end)
  end

  @doc """
  Convert phone number to 1 213 333 4444
  """
  @spec phone_number_formatter(String.t) :: String.t
  def phone_number_formatter(phone_number) do
    formatted_phone_number = phone_number
      |> String.replace([" ", "-", ")", "(", "="], "")
    "1" <> formatted_phone_number
  end

  @doc """
  Convert phone number to  213 333 4444
  """
  @spec phone_number_formatter(String.t) :: String.t
  def phone_number_formatter_without_one(phone_number) do
    formatted_phone_number = phone_number
      |> String.replace([" ", "-", ")", "(", "="], "")
    formatted_phone_number
  end

  @doc """
  Convert phone number from
  +12223334444 to
  12223334444
  """
  def remove_plus_sign_from_phonenumber(phone_number) do
    String.slice(phone_number, 1, 12)
  end

  @doc """
  Convert phone number from 1 213 333 4444
  to (213)333-4444 for display purpose
  """
  def display_phone_number(phone_number) do
    {_, phone_number } = String.split_at(phone_number, 1)
    {area_code, phone_number} = String.split_at(phone_number, 3)
    {head, tail} = String.split_at(phone_number, 3)
    new_format = "(#{area_code}) #{head}-#{tail}"
    new_format
  end

  def convert_map_to_struct(map) do
    for {key, val} <- map, into: %{} do
      {String.to_existing_atom(key), val}
    end
  end

  def stripe_money_converter(amount) when is_binary(amount) do
    {correct_format_amount, _} = Integer.parse(amount)
    div(correct_format_amount, 100)
  end

  def stripe_money_converter(amount) do
    div(amount, 100)
  end

  def get_user_area_code(user) do
    phonenumber = user.phone_number
    area_code = String.slice(phonenumber, 1, 3)
    {area_code, ""} = Integer.parse(area_code)
    area_code
  end

  def unix_time_to_normal_time(time) do
    Timex.from_unix(time)
  end

  def display_date_time(datetime) do
    {:ok, datetime} = Timex.format(datetime, "%m-%d-%Y", :strftime)
    datetime
  end

  def stripe_money_to_currency(amount) when is_binary(amount) do
    {amount, ""} = Integer.parse(amount)
    amount / 100 |> Number.Currency.number_to_currency()
  end

  def stripe_money_to_currency(amount) do
    amount / 100 |> Number.Currency.number_to_currency()
  end



  def display_percentage(number) do
    Number.Percentage.number_to_percentage(number, precision: 0)
  end
end