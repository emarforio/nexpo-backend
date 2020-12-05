defmodule Nexpo.FormResponse do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.FormResponse

  schema "form_responses" do
    field(:data, {:array, :map})

    belongs_to(:form, Nexpo.Form, foreign_key: :form_id)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:form_id, :data])
    |> validate_required([:form_id, :data])
    |> foreign_key_constraint(:form_id)
  end

  def build_assoc!(form_response, form_id) do
    form_response
    |> FormResponse.changeset(%{form_id: form_id})
    |> Repo.update!()
  end
end
