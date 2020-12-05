defmodule Nexpo.ResponseHandler do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.ResponseHandler

  schema "response_handlers" do
    field(:accept, :boolean)
    field(:rating, :boolean)
    field(:comment, :boolean)

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:accept, :rating, :comment, :form_config_id])
    |> validate_required([:accept, :rating, :comment, :form_config_id])
    |> foreign_key_constraint(:form_config_id)
  end

  def build_assoc!(response_handler, form_config_id) do
    response_handler
    |> ResponseHandler.changeset(%{form_config_id: form_config_id})
    |> Repo.update!()
  end
end