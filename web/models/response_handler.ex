defmodule Nexpo.ResponseHandler do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "response_handlers" do
    field(:accept, :boolean)
    field(:rating, :boolean)
    field(:comment, :boolean)

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:accept, :rating, :comment])
    |> validate_required([:accept, :rating, :comment])
    |> foreign_key_constraint(:form_config_id)
  end
end