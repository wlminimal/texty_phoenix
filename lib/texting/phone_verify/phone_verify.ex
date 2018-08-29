defmodule Texting.PhoneVerify do
  alias Messageman

  def phone_verify_start(phone_number) do
    with {:ok, message} <- Messageman.verify_start(phone_number) do
      {:ok, message}
    else
      {:error, reason, _http_status_code} -> {:error, reason}
    end
  end

  def phone_verify_check(phone_number, code_number) do
    with {:ok, message} <- Messageman.verify_check(phone_number, code_number) do
      {:ok, message}
    else
      {:error, reason, _http_status_code} ->
        {:error, reason}
    end
  end
end
