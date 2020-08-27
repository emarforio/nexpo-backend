defmodule Nexpo.EventInfo do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.EventInfo

  schema "event_infos" do
    field(:host, :string)
    field(:description, :string)
    field(:language, :string)
    field(:tickets, :integer, default: 0)

    belongs_to(:event, Nexpo.Event, foreign_key: :event_id)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :host, :description])
    |> cast(params, [:tickets])
    |> validate_required([:event_id])
    |> foreign_key_constraint(:event_id)
  end

  def build_assoc!(event_info, event_id) do
    event_info
    |> EventInfo.changeset(%{event_id: event_id})
    |> Repo.update!()
  end
end
