defmodule Nexpo.DeadlineController do
  use Nexpo.Web, :controller

  alias Nexpo.Deadline
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [handler: Nexpo.SessionController, default: ["read_all"]] when action in [:index, :show]
  )

  plug(
    EnsurePermissions,
    [handler: Nexpo.SessionController, default: ["write_all"]]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/deadlines Get all deadlines
  @apiGroup Deadlines
  @apiDescription Fetch all available deadlines
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    deadlines = Repo.all(Deadline)
    render(conn, "index.json", deadlines: deadlines)
  end

  @apidoc """
  @api {POST} /api/deadlines Create a deadline
  @apiGroup Deadlines
  @apiDescription Create a deadline
  @apiParam {String}  deadline.name   Name of deadline (application deadline etc)
  @apiParam {Naive_datetime}  deadline.start   Start of deadline
  @apiParam {Naive_datetime}  deadline.end   End of deadline
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "name": "Host Applications",
      "start": "2000-01-01 23:00:00",
      "end": "2040-01-01 23:00:00",
      "id": 1
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"deadline" => deadline_params}) do
    changeset = Deadline.changeset(%Deadline{}, deadline_params)

    case Repo.insert(changeset) do
      {:ok, deadline} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", deadline_path(conn, :show, deadline))
        |> render("show.json", deadline: deadline)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/deadlines/:id Get a deadline
  @apiGroup Deadlines
  @apiDescription Fetch a single deadline
  @apiParam {Integer} id    Id of the deadline
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    deadline = Repo.get!(Deadline, id)
    render(conn, "show.json", deadline: deadline)
  end

  @apidoc """
  @api {PUT} /api/deadlines/:id Update a deadline
  @apiGroup Deadlines
  @apiDescription Update a deadline
  @apiParam {String}  deadline.name   Name of deadline (application deadline etc)
  @apiParam {Naive_datetime}  deadline.start   Start of deadline
  @apiParam {Naive_datetime}  deadline.end   End of deadline
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "deadline" => deadline_params}) do
    deadline = Repo.get!(Deadline, id)
    changeset = Deadline.changeset(deadline, deadline_params)

    case Repo.update(changeset) do
      {:ok, deadline} ->
        render(conn, "show.json", deadline: deadline)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/deadlines/:id Delete a deadline
  @apiGroup Deadlines
  @apiDescription Completely remove a deadline
  @apiParam {Integer}  id   Id of deadline
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    deadline = Repo.get!(Deadline, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(deadline)

    send_resp(conn, :no_content, "")
  end
end
