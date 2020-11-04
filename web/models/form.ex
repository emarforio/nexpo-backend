defmodule Nexpo.Form do
  use Nexpo.Web, :model
  use Arc.Ecto.Schema

  schema "forms" do
    field(:template, :string)

    has_one(:form_config, Nexpo.FormConfig, on_delete: :delete_all)
    has_many(:form_responses, Nexpo.FormResponse, on_delete: :delete_all)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:template])
    |> validate_required([:template])
  end
end
