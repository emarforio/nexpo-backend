defmodule Nexpo.InterestController do
  use Nexpo.Web, :controller

  alias Nexpo.Interest
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}]
    ]
    when action in [:show]
  )

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}]
    ]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/interests Get all interests
  @apiGroup Interests
  @apiDescription Fetch all available interests
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    interests = Repo.all(Interest)
    render(conn, "index.json", interests: interests)
  end

  @apidoc """
  @api {POST} /api/interests Create an interest
  @apiGroup Interests
  @apiDescription Create an interest
  @apiParam {String}  interest.name   Name of interest
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "name": "interest1",
      "id": 1
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"interest" => interest_params}) do
    changeset = Interest.changeset(%Interest{}, interest_params)

    case Repo.insert(changeset) do
      {:ok, interest} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", interest_path(conn, :show, interest))
        |> render("show.json", interest: interest)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/interests/:id Get an interest
  @apiGroup Interests
  @apiDescription Fetch a single interest
  @apiParam {Integer} id    Id of the interest
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    interest =
      Interest
      |> Repo.get!(id)
      |> Repo.preload(:students)

    render(conn, "show.json", interest: interest)
  end

  @apidoc """
  @api {PUT} /api/interests/:id Update an interest
  @apiGroup Interests
  @apiDescription Update an interest
  @apiParam {Integer}  id   Id of interest
  @apiParam {String}  interest.name   Name of interest
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "interest" => interest_params}) do
    interest = Repo.get!(Interest, id)
    changeset = Interest.changeset(interest, interest_params)

    case Repo.update(changeset) do
      {:ok, interest} ->
        render(conn, "show.json", interest: interest)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/interests/:id Delete an interest
  @apiGroup Interests
  @apiDescription Completely remove an interest
  @apiParam {Integer}  id   Id of interest
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    interest = Repo.get!(Interest, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(interest)

    send_resp(conn, :no_content, "")
  end
end
