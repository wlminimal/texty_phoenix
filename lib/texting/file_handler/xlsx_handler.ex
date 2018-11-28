defmodule Texting.FileHandler.XlsxHandler do
  alias Texting.Messenger

  def read!(filename) do
    {:ok, table_id} = Xlsxir.multi_extract(filename, 0)
    contact_list = Xlsxir.get_list(table_id)
    # Delete ETC process
    Xlsxir.close(table_id)
    # cut header line (name, phone_number)
    [_header | contacts] = contact_list

    # convert list to map
    for [name, phone_number] <- contacts do
      %{"name" => name, "phone_number" => "#{phone_number}"}
    end
  end

  @doc """
  Filter out landline number
  """
  def read_only_mobile_number!(filename) do
    {:ok, table_id} = Xlsxir.multi_extract(filename, 0)
    contact_list = Xlsxir.get_list(table_id)
    # Delete ETC process
    Xlsxir.close(table_id)
    # cut header line (name, phone_number)
    [_header | contacts] = contact_list

    contacts =
      Enum.reject(contacts, fn [_name | phone_number] ->
        Enum.empty?(phone_number)
      end)
      |> Enum.reject(fn [_name, phone_number] ->
        Messenger.is_landline_number?(Integer.to_string(phone_number))
      end)

    # convert list to map
    for [name, phone_number] <- contacts do
      %{"name" => name, "phone_number" => "#{phone_number}"}
    end
  end
end
