defmodule Nexpo.CoordinatorPosition do
  use Nexpo.Web, :model

  alias Nexpo.Repo
  alias Nexpo.CoordinatorPosition

  schema "coordinator_positions" do
    field(:type, :string)
    field(:position, :string)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:type, :position])
    |> validate_required([:type, :position])
    |> unique_constraint(:position, message: "Position already exists")
  end

end