defmodule Nexpo.FormResponse do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "form_responses" do
    field(:data, {:array, :map})

    belongs_to(:form, Nexpo.Form, foreign_key: :form_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:data])
    |> validate_required([:data])
    |> foreign_key_constraint(:form_id)
  end
end
