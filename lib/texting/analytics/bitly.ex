defmodule Texting.Bitly do
  use Ecto.Schema
  import Ecto.Changeset
  alias Texting.Account.User
  alias Texting.Bitly
  alias Texting.Repo
  import Ecto.Query
  alias Texting.Sales.Order

  schema "bitly" do
    field :bitlink_id, :string
    field :bitlink_url, :string
    field :long_url, :string
    field :total_clicks, :integer, default: 0
    field :status, :string
    field :user_id, :integer
    field :order_id, :integer

    belongs_to :user, User, define_field: false
    belongs_to :orders, Order, define_field: false
    timestamps()
  end

  @doc false
  def changeset(%Bitly{} = bitly, attrs) do
    bitly
    |> cast(attrs, [:bitlink_id, :bitlink_url, :long_url, :total_clicks, :user_id, :order_id])
    |> foreign_key_constraint(:order_id)
    |> validate_required([:bitlink_id, :bitlink_url, :long_url, :total_clicks, :user_id, :order_id])
  end

  def confirm_changeset(%Bitly{} = bitly, attrs \\ %{}) do
    attrs = Map.put(attrs, "status", "Saved")
    changeset(bitly, attrs)
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  @spec create_bitly(
          :invalid
          | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: any()
  def create_bitly(attrs \\ %{}) do
    %Bitly{status: "Not Saved"}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(changeset), do: Repo.update(changeset)

  def update(bitly, attrs) do
    bitly
    |> changeset(attrs)
    |> Repo.update
  end





  def get_bitly_by_order_id(order_id) do
    query = from b in Bitly, where: b.order_id == ^order_id and b.status == "Saved"
    Repo.one(query)
  end

  def get_bitly_by_id(bitly_id) do
    query = from b in Bitly, where: b.id == ^bitly_id
    Repo.one(query)
  end

  def get_bitly_by_status(order_id, status) do
    query = from b in Bitly, where: b.order_id == ^order_id and b.status == ^status
    Repo.all(query)
  end
end
