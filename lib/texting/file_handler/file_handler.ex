defmodule Texting.FileHandler do

  @extension_whitelist ~w(.csv .xlsx)
  @image_extension_whitelist ~w(.png .jpg .jpeg)
  @validate_file_size 2000000 # 2.0 MB

  def validate_text_file?(file) do
    file_extension = get_extension(file)
    results = Enum.member?(@extension_whitelist, file_extension)
    results
  end

  def validate_image_file?(file) do
    file_extension = get_extension(file)
    results = Enum.member?(@image_extension_whitelist, file_extension)
    results
  end

  def validate_size?(file) do
    {:ok, %{size: size}} = File.stat(file.path)
    cond do
      size > @validate_file_size -> false
      size <= @validate_file_size -> true
    end
  end

  def get_extension(file) do
    file_extension = file.filename |> Path.extname |> String.downcase
    file_extension
  end
end
