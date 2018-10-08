defmodule Texting.FileHandler.XlsxHandler do

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

end
