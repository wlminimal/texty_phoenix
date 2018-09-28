defmodule Texting.AmazonS3.S3Helpers do

  alias UUID
  alias ExAws.S3

  @one_week 60 * 60 * 24 * 7

  @doc """
  Append user id in s3 filename so looks like this
  123/filename.jpg
  """
  def create_s3_file_name(file_extension, user) do
    file_uuid = UUID.uuid4(:hex)
    s3_filename = "#{user.id}/#{file_uuid}#{file_extension}"
    s3_filename
  end

  def get_bucket_name(), do: System.get_env("AWS_S3_BUCKET_NAME")

  def upload_file_to_S3(bucket_name, s3_filename, file_binary) do
    S3.put_object(bucket_name, s3_filename, file_binary, [{:acl, :public_read}])
    |> ExAws.request()
    config = get_aws_s3_config()
    bucket = get_bucket_name()
    {:ok, url} = get_presigned_url(config, :get, bucket, s3_filename, @one_week)
    {:ok, url}
  end

  def get_aws_s3_config() do
    ExAws.Config.new(:s3)
  end

  def get_presigned_url(config, http_method, bucket, filename, exp) do
    ExAws.S3.presigned_url(config, http_method, bucket, filename, [expires_in: exp ])
  end


end
