defmodule Nexpo.EventTicket do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema
  alias Nexpo.Repo
  alias Nexpo.EventTicket

  schema "event_tickets" do
    field(:ticket_code, :string)
    field(:photo, :boolean)
    belongs_to(:student, Nexpo.Student, foreign_key: :student_id)
    belongs_to(:event, Nexpo.Event, foreign_key: :event_id)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :student_id, :photo, :ticket_code])
    |> validate_required([:event_id, :student_id, :photo, :ticket_code])
    |> foreign_key_constraint(:event_id)
    |> foreign_key_constraint(:student_id)
    |> unique_constraint(:ticket_constraint, name: :event_ticket_index)
  end

  def create_ticket(event_ticket) do
    %EventTicket{}
    |> EventTicket.changeset(event_ticket)
    |> Repo.insert()
  end
end
