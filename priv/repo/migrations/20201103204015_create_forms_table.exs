defmodule Nexpo.Repo.Migrations.CreateFormsTable do
  use Ecto.Migration

  def change do
    create table(:forms) do
      add(:template, :string)

      timestamps()
    end
  end
end