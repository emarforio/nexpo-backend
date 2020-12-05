defmodule Nexpo.ResponseStruct do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.ResponseStruct

  schema "response_structs" do
    field(:keys, {:array, :integer})

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:keys, :form_config_id])
    |> validate_required([:keys, :form_config_id])
    |> foreign_key_constraint(:form_config_id)
  end

  def build_assoc!(response_structs, form_config_id) do
    response_structs
    |> ResponseStruct.changeset(%{form_config_id: form_config_id})
    |> Repo.update!()
  end
end
