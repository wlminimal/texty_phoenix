defmodule TextingWeb.Dashboard.UploadContactController do
  use TextingWeb, :controller

  alias Texting.FileHandler
  alias Texting.FileHandler.{CsvHandler, XlsxHandler}
  alias Texting.Contact

  def new(conn, _params) do
    # Get phonebook list and
    # Make list ["Phonebook_name": "phonebook_id"]
    user = conn.assigns.current_user

    phonebooks =
      Contact.list_phonebooks(user.id)
      |> Enum.reject(&(&1.name == "Unsubscriber"))
      |> Enum.reject(&(&1.name == "Subscriber"))

    render(conn, "index.html", phonebooks: phonebooks)
  end

  # Backup
  # def upload(conn, %{"name" => phonebook_name,
  #                    "contact_csv" => %Plug.Upload{filename: filename, path: path} = file}) do
  #   user = conn.assigns.current_user
  #   IO.puts "++++ file path++++"
  #   IO.inspect path
  #   IO.inspect filename
  #   # Check if file is csv or xlsx

  #   try do
  #     contacts_map = CsvHandler.read!(path)

  #     case Contact.create_phonebook(user, %{"name" => phonebook_name}) do
  #       {:ok, phonebook} ->
  #         #Enum.map(contacts_map, &CsvHandler.convert_to_person(&1, phonebook, user))
  #        try do
  #         Task.Supervisor.async_stream(TextingWeb.TaskSupervisor, contacts_map,
  #         Texting.FileHandler.CsvHandler, :convert_to_person, [phonebook, user], [max_concurrency: 20])
  #         |> Enum.to_list()
  #         conn
  #         |> put_flash(:info, "Contacts created successfully. Check your phonebook!")
  #         |> redirect(to: phonebook_path(conn, :index))
  #        rescue
  #         _ ->
  #           conn
  #           |> put_flash(:error, "Please upload only .csv format or check your file contents")
  #           |> redirect(to: upload_contact_path(conn, :new))
  #        end

  #       {:error, _changeset} ->
  #         conn
  #         |> put_flash(:error, "Phonebook name '#{phonebook_name}' already taken, Please use other name")
  #         |> redirect(to: upload_contact_path(conn, :new))
  #     end
  #   rescue
  #     _e in CSV.RowLengthError ->
  #       conn
  #       |> put_flash(:error, "Please upload only .csv format or check your file contents")
  #       |> redirect(to: upload_contact_path(conn, :new))
  #     _ ->
  #       conn
  #       |> put_flash(:error, "Please upload only .csv format or check your file contents")
  #       |> redirect(to: upload_contact_path(conn, :new))
  #   end
  # end

  @doc """
  Upload contacts file to new phonebook
  """
  def upload(conn, %{
        "name" => phonebook_name,
        "contact_csv" => %Plug.Upload{filename: filename, path: path} = file
      }) do
    user = conn.assigns.current_user
    IO.puts("++++ file path++++")
    IO.inspect(path)
    IO.inspect(filename)
    # Check if file is csv or xlsx
    with true <- FileHandler.validate_text_file?(file),
         true <- FileHandler.validate_size?(file) do
      file_extension = FileHandler.get_extension(file)

      cond do
        file_extension == ".xlsx" ->
          # handle xlsx file
          try do
            contacts_map = XlsxHandler.read!(path)

            # Create a phonebook to upload
            case Contact.create_phonebook(user, %{"name" => phonebook_name}) do
              {:ok, phonebook} ->
                # Enum.map(contacts_map, &CsvHandler.convert_to_person(&1, phonebook, user))
                upload_contacts_async(conn, contacts_map, phonebook, user)

              {:error, _changeset} ->
                conn
                |> put_flash(
                  :error,
                  "Phonebook name '#{phonebook_name}' already taken, Please use other name"
                )
                |> redirect(to: upload_contact_path(conn, :new))
            end
          rescue
            _ ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))
          end

        file_extension == ".csv" ->
          # hander csv file
          try do
            contacts_map = CsvHandler.read!(path)

            # Create a phonebook to upload
            case Contact.create_phonebook(user, %{"name" => phonebook_name}) do
              {:ok, phonebook} ->
                # Enum.map(contacts_map, &CsvHandler.convert_to_person(&1, phonebook, user))
                upload_contacts_async(conn, contacts_map, phonebook, user)

              {:error, _changeset} ->
                conn
                |> put_flash(
                  :error,
                  "Phonebook name '#{phonebook_name}' already taken, Please use other name"
                )
                |> redirect(to: upload_contact_path(conn, :new))
            end
          rescue
            _e in CSV.RowLengthError ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))

            _ ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))
          end

        true ->
          # error
          conn
          |> put_flash(:error, "Please upload only csv or xlsx file.")
          |> redirect(to: upload_contact_path(conn, :new))
      end
    else
      false ->
        conn
        |> put_flash(:error, "Please upload only csv or xlsx and max file size is 2 MB.")
        |> redirect(to: upload_contact_path(conn, :new))
    end
  end

  @doc """
  Upload file to existing phonebook
  """
  def upload(conn, %{
        "phonebook_id" => phonebook_id,
        "contact_csv" => %Plug.Upload{filename: filename, path: path} = file
      }) do
    user = conn.assigns.current_user
    phonebook = Contact.get_phonebook!(phonebook_id, user.id)

    with true <- FileHandler.validate_text_file?(file),
         true <- FileHandler.validate_size?(file) do
      file_extension = FileHandler.get_extension(file)

      cond do
        file_extension == ".xlsx" ->
          # Handle xlsx file
          try do
            contacts_map = XlsxHandler.read!(path)
            # contacts_map = XlsxHandler.read_only_mobile_number!(path)
            upload_contacts_async(conn, contacts_map, phonebook, user)
          rescue
            _ ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))
          end

        file_extension == ".csv" ->
          # Handle csv file
          try do
            contacts_map = CsvHandler.read!(path)
            # Enum.map(contacts_map, &CsvHandler.convert_to_person(&1, phonebook, user))
            upload_contacts_async(conn, contacts_map, phonebook, user)
          rescue
            _e in CSV.RowLengthError ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))

            _ ->
              conn
              |> put_flash(:error, "Please check your file contents")
              |> redirect(to: upload_contact_path(conn, :new))
          end

        true ->
          # error
          conn
          |> put_flash(:error, "Please upload only csv or xlsx file.")
          |> redirect(to: upload_contact_path(conn, :new))
      end
    else
      false ->
        conn
        |> put_flash(:error, "Please upload only csv or xlsx and max file size is 2 MB.")
        |> redirect(to: upload_contact_path(conn, :new))
    end
  end

  def upload(conn, _), do: conn |> redirect(to: upload_contact_path(conn, :new))

  # Convert to person struct asynchronously
  defp upload_contacts_async(conn, contacts_map, phonebook, user) do
    try do
      Task.Supervisor.async_stream(
        TextingWeb.TaskSupervisor,
        contacts_map,
        Texting.FileHandler.CsvHandler,
        :convert_to_person,
        [phonebook, user],
        max_concurrency: 20
      )
      |> Enum.to_list()

      conn
      |> put_flash(:info, "Contacts created successfully. Check your phonebook!")
      |> redirect(to: phonebook_path(conn, :index))
    rescue
      _ ->
        conn
        |> put_flash(:error, "Can't upload your file. Please check your file contents.")
        |> redirect(to: upload_contact_path(conn, :new))
    end
  end
end
