defmodule Nexpo.DesiredProgrammeController do
  use Nexpo.Web, :controller

  alias Nexpo.{Company, DesiredProgramme}
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [handler: Nexpo.SessionController, default: ["write_all"]] when action in [:create]
  )

  @apidoc """
  @api {POST} /api/desired_programmes Create a desired programme
  @apiGroup Desired Programmes
  @apiDescription Create a desired programme 
  @apiParam {json} desired_programme   Nested JSON object containing below fields 
  @apiParam {Integer} desired_programme.score     Score
  @apiParam {Integer} desired_programme.company_id    Desired company id
  @apiParam {Integer} desired_programme.programme_id    Desired programme id
  @apiParam {Integer} company_id Company id
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "user_id": 3,
      "id": 6,
      "company_id": 2
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"desired_programme" => desired_programmes_params, "company_id" => company_id}) do
    data = Map.put(desired_programmes_params, "company_id", company_id)
    company = Repo.get(Company, company_id)

    changeset =
      company
      |> Ecto.build_assoc(:desired_programmes)
      |> DesiredProgramme.changeset(data)

    case Repo.insert(changeset) do
      {:ok, _programme} ->
        conn
        |> redirect(to: company_path(conn, :show, company))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
