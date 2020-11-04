defmodule Nexpo.Repo.Migrations.CreateAutoResponsesTable do
  use Ecto.Migration

  def change do
    create table(:auto_responses) do
      add(:recipient, :string)
      add(:subject, :string)
      add(:body, :string)
      add(:form_config_id, references(:form_configs))

      timestamps()
    end
  end
end
