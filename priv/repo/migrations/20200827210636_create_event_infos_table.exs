defmodule Nexpo.Repo.Migrations.CreateEventInfosTable do
  use Ecto.Migration

  def change do
    create table(:event_infos) do
      add(:host, :string)
      add(:description, :string)
      add(:language, :string)
      add(:event_id, references(:events))

      timestamps()
    end
  end
end
