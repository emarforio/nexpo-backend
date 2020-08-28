defmodule Nexpo.Repo.Migrations.CreateEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:name, :string)
      add(:date, :string)
      add(:start, :string)
      add(:end, :string)
      add(:location, :string)

      timestamps()
    end
  end
end
