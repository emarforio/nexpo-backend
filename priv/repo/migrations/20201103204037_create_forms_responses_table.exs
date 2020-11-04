defmodule Nexpo.Repo.Migrations.CreateFormsResponsesTable do
  use Ecto.Migration

  def change do
    create table(:form_responses) do
      add(:data, {:array, :map})
      add(:form_id, references(:forms))
    end
  end
end

