defmodule Nexpo.Repo.Migrations.AddTicketCodeToEventTickets do
  use Ecto.Migration

  def change do
    alter table(:event_tickets) do
      add(:ticket_code, :string)
    end
  end
end
