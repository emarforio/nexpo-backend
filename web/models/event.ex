defmodule Nexpo.Event do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "events" do
    field(:name, :string)
    field(:date, :string)
    field(:start, :string)
    field(:end, :string)
    field(:location, :string)

    has_one(:event_info, Nexpo.EventInfo, on_delete: :delete_all)

    has_many(:event_tickets, Nexpo.EventTicket, on_delete: :delete_all)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :date, :start, :end, :location])
    |> validate_required([:name])
  end
end
