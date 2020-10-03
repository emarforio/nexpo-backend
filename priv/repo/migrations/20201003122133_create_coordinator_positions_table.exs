defmodule Nexpo.Repo.Migrations.CreateCoordinatorPositionsTables do
  use Ecto.Migration

  def change do
    create table(:coordinator_positions) do
      add(:type, :string)
      add(:position, :string)

      timestamps()
    end
  end
end
