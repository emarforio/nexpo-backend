defmodule Nexpo.Repo.Migrations.CreateEventTicketIndex do
  use Ecto.Migration

  def change do
    create index(:event_tickets, [:student_id, :event_id], unique: true, name: :event_ticket_index)
  end
end
