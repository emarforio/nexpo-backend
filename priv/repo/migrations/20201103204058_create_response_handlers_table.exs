defmodule Nexpo.Repo.Migrations.CreateResponseHandlersTable do
  use Ecto.Migration

  def change do
    create table(:response_handlers) do
      add(:accept, :boolean)
      add(:rating, :boolean)
      add(:comment, :boolean)
      add(:form_config_id, references(:form_configs))

      timestamps()
    end
  end
end
