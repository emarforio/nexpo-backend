defmodule Nexpo.ProgrammeController do
  use Nexpo.Web, :controller

  alias Nexpo.Programme

  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}, %{default: ["write_users"]}]
    ]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/programmes Get all programmes
  @apiGroup Programmes
  @apiDescription Fetch all available programmes
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    programmes = Repo.all(Programme)
    render(conn, "index.json", programmes: programmes)
  end

  @apidoc """
  @api {POST} /api/programmes Create a programme
  @apiGroup Programmes
  @apiDescription Create a programme
  @apiParam {String}  programme.code   Code of programme (C, D etc)
  @apiParam {String}  programme.name   Name of programme
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "code": "D",
      "name": "D-Guild",
      "id": 1
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"programme" => programme_params}) do
    changeset = Programme.changeset(%Programme{}, programme_params)

    case Repo.insert(changeset) do
      {:ok, programme} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", programme_path(conn, :show, programme))
        |> render("show.json", programme: programme)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/programmes/:id Get a programme
  @apiGroup Programmes
  @apiDescription Fetch a single programme
  @apiParam {Integer} id    Id of the programme
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    programme =
      Programme
      |> Repo.get!(id)
      |> Repo.preload(:desired_programmes)

    render(conn, "show.json", programme: programme)
  end

  @apidoc """
  @api {PUT} /api/programmes/:id Update a programme
  @apiGroup Programmes
  @apiDescription Update a programme
  @apiParam {String}  programme.code   Code of programme (C, D etc)
  @apiParam {String}  programme.name   Name of programme
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "programme" => programme_params}) do
    programme = Repo.get!(Programme, id)
    changeset = Programme.changeset(programme, programme_params)

    case Repo.update(changeset) do
      {:ok, programme} ->
        render(conn, "show.json", programme: programme)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/programmes/:id Delete a programme
  @apiGroup Programmes
  @apiDescription Completely remove a programme
  @apiParam {Integer}  id   Id of programme
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    programme = Repo.get!(Programme, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(programme)

    send_resp(conn, :no_content, "")
  end
end
