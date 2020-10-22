defmodule Nexpo.Repo.Migrations.AddPhotoToEventTickets do
  use Ecto.Migration

  def change do
    alter table(:event_tickets) do
      add(:photo, :boolean)
    end
  end
end