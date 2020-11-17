defmodule Nexpo.RepresentativeController do
  use Nexpo.Web, :controller

  alias Nexpo.Representative
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}, %{default: ["read_users"]}]
    ]
    when action in [:index, :show]
  )

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}, %{default: ["write_users"]}]
    ]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/representatives Get all representatives
  @apiGroup Representatives
  @apiDescription Fetch all available representatives
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    representatives = Repo.all(Representative)
    render(conn, "index.json", representatives: representatives)
  end

  @apidoc """
  @api {POST} /api/representatives Create a representative
  @apiGroup Representatives
  @apiDescription Create a representative 
  @apiParam {Integer}  user_id   User id
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
  def create(conn, %{"representative" => representative_params}) do
    changeset = Representative.changeset(%Representative{}, representative_params)

    case Repo.insert(changeset) do
      {:ok, representative} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", representative_path(conn, :show, representative))
        |> render("show.json", representative: representative)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/representatives/:id Get a representative
  @apiGroup Representatives
  @apiDescription Fetch a single representative
  @apiParam {Integer} id    Id of the representative
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    representative = Repo.get!(Representative, id)
    render(conn, "show.json", representative: representative)
  end

  @apidoc """
  @api {PUT} /api/representatives/:id Update a representative
  @apiGroup Representatives
  @apiDescription Update a representative
  @apiParam {Integer}  id   Id of representative
  @apiParam {json} representative   Nested JSON object containing below fields 
  @apiParam {Integer} representative.user_id User id
  @apiParam {Integer} representative.company_id Company id
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "representative" => representative_params}) do
    representative = Repo.get!(Representative, id)
    changeset = Representative.changeset(representative, representative_params)

    case Repo.update(changeset) do
      {:ok, representative} ->
        render(conn, "show.json", representative: representative)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/representatives/:id Delete a representative
  @apiGroup Representatives
  @apiDescription Completely remove a representative
  @apiParam {Integer} id    Id of the representative
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    representative = Repo.get!(Representative, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(representative)

    send_resp(conn, :no_content, "")
  end
end
