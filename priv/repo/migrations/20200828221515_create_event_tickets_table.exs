defmodule Nexpo.Repo.Migrations.CreateEventTicketsTable do
  use Ecto.Migration

  def change do
    create table(:event_tickets) do
      add(:event_id, references(:events))
      add(:student_id, references(:students))

      timestamps()
    end
  end
end