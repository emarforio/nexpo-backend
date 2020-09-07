defmodule Nexpo.EventTicket do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.EventTicket

  schema "event_tickets" do

    belongs_to(:student, Nexpo.Student, foreign_key: :student_id)
    belongs_to(:event, Nexpo.Event, foreign_key: :event_id)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :student_id])
    |> validate_required([:event_id, :student_id])
    |> foreign_key_constraint(:event_id, :student_id)
  end
end
