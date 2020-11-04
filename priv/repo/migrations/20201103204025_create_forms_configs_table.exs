defmodule Nexpo.Repo.Migrations.CreateFormsConfigsTable do
  use Ecto.Migration

  def change do
    create table(:form_configs) do
      add(:deadline, :utc_datetime)
      add(:max_response, :integer)
      add(:published, :boolean)
      add(:form_id, references(:forms))

      timestamps()
    end
  end
end
