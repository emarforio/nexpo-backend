defmodule Nexpo.AutoResponse do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  alias Nexpo.Repo
  alias Nexpo.AutoResponse

  schema "auto_responses" do
    field(:recipient, :string)
    field(:subject, :string)
    field(:body, :string)

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:recipient, :subject, :body, :form_config_id])
    |> validate_required([:recipient, :subject, :body, :form_config_id])
    |> foreign_key_constraint(:form_config_id)
  end

  def build_assoc!(auto_response, form_config_id) do
    auto_response
    |> AutoResponse.changeset(%{form_config_id: form_config_id})
    |> Repo.update!()
  end
end
