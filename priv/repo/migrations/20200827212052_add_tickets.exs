defmodule Nexpo.Repo.Migrations.AddTickets do
  use Ecto.Migration

  def change do
    alter table(:event_infos) do
      add(:tickets, :integer)
    end
  end
end
