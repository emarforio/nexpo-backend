defmodule Nexpo.Repo.Migrations.CreateResponseStructsTable do
  use Ecto.Migration

  def change do
    create table(:response_structs) do
      add(:keys, {:array, :int})
      add(:form_config_id, references(:form_configs))

      timestamps()
    end
  end
end