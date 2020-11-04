defmodule Nexpo.ResponseStruct do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "response_structs" do
    field(:keys, {:array, :int})

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:keys])
    |> validate_required([:keys])
    |> foreign_key_constraint(:form_config_id)
  end
end
