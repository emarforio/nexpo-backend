defmodule Nexpo.AutoResponse do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "auto_responses" do
    field(:recipient, :string)
    field(:subject, :string)
    field(:body, :string)

    belongs_to(:form_config, Nexpo.Form, foreign_key: :form_config_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:recipient, :subject, :body])
    |> validate_required([:recipient, :subject, :body])
    |> foreign_key_constraint(:form_config_id)
  end
end
