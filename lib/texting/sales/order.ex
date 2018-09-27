defmodule Texting.Sales.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Sales.{Order, LineItem}
  alias Texting.Account.User
  alias Texting.Messenger.MessageStatus


  schema "orders" do
    field :name, :string
    field :description, :string
    field :counts, :integer
    field :status, :string
    embeds_many :line_items, LineItem, on_replace: :delete
    field :user_id, :integer
    field :message_type, :string
    field :total, :decimal
    field :message, :string
    field :media_url, :string
    field :media_url_exp, :naive_datetime
    field :s3_filename, :string
    field :scheduled, :boolean, default: false
    field :schedule_job_success, :boolean, default: false
    field :schedule_datetime, :naive_datetime
    field :bitly_id, :integer
    belongs_to :users, User, define_field: false


    has_many :message_status, MessageStatus
    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:status, :counts, :user_id, :name, :description, :message, :total, :media_url, :s3_filename, :media_url_exp, :scheduled, :schedule_job_success, :schedule_datetime, :bitly_id])
    |> cast_embed(:line_items, with: &LineItem.changeset/2)
    |> validate_required([:status, :counts, :user_id])
  end

  def checkout_changeset(%Order{} = order, attrs) do
    changeset(order, attrs)
    |> cast(attrs, [:message_type, :media_url_exp])
    |> validate_required([:user_id, :message_type, :total, :message])
  end
end
