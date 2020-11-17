defmodule Nexpo.IndustryController do
  use Nexpo.Web, :controller

  alias Nexpo.{Industry, Company}
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}, %{default: ["read_companies"]}]
    ]
    when action in [:index, :show]
  )

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}, %{default: ["write_companies"]}]
    ]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/industries Get all industries
  @apiGroup Industries
  @apiDescription Fetch all available industries
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    industries = Repo.all(Industry)
    render(conn, "index.json", industries: industries)
  end

  @apidoc """
  @api {POST} /api/industries Create an industry
  @apiGroup Industries
  @apiDescription Create an industry
  @apiParam {String}  industry.name   Name of industry
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "name": "dil",
      "id": 1
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"industry" => industry_params}) do
    changeset = Industry.changeset(%Industry{}, industry_params)

    case Repo.insert(changeset) do
      {:ok, industry} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", industry_path(conn, :show, industry))
        |> render("show.json", industry: industry)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/representatives/:id Get an industry
  @apiGroup Industries
  @apiDescription Fetch a single industry
  @apiParam {Integer} id    Id of the industry
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    industry =
      Repo.get!(Industry, id)
      |> Repo.preload([:companies])

    render(conn, "show.json", industry: industry)
  end

  @apidoc """
  @api {PUT} /api/industries/:id Update an industry
  @apiGroup Industries
  @apiDescription Update an industry
  @apiParam {Integer}  id   Id of industry
  @apiParam {String}  industry.name   Name of industry
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "industry" => industry_params}) do
    industry =
      Repo.get!(Industry, id)
      |> Repo.preload(:companies)

    changeset =
      Industry.changeset(industry, industry_params)
      |> Company.put_assoc(industry_params)

    case Repo.update(changeset) do
      {:ok, industry} ->
        render(conn, "show.json", industry: industry)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/industries/:id Delete a industry
  @apiGroup Industries
  @apiDescription Completely remove a industry
  @apiParam {Integer}  id   Id of industry
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    industry = Repo.get!(Industry, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(industry)

    send_resp(conn, :no_content, "")
  end
end
