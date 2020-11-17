defmodule Nexpo.RoleController do
  use Nexpo.Web, :controller

  alias Nexpo.{Role, User}
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}, %{default: ["read_roles"]}]
    ]
    when action in [:index, :show]
  )

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}, %{default: ["write_roles"]}]
    ]
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/roles Get all roles
  @apiGroup Roles
  @apiDescription Fetch all available roles
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
      {
          "type": "admin",
          "permissions": [
              "read_all",
              "write_all"
          ],
          "id": 1
      },
      {
          "type": "company",
          "permissions": [
              "read_company",
              "write_company"
          ],
          "id": 2
      }
    ]
  }
  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    roles = Repo.all(Role)
    render(conn, "index.json", roles: roles)
  end
  
  @apidoc """
  @api {POST} /api/roles Create role
  @apiGroup Roles
  @apiDescription Create a role 
  @apiParam {json} role   Nested JSON object containing below fields 
  @apiParam {String} role.type   Role (admin, student)
  @apiParam {String[]} role.permissions   Permissions for role

  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "type": "student",
      "permissions": [],
      "id": 4
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"role" => role_params}) do
    changeset =
      Role.changeset(%Role{}, role_params)
      |> User.put_assoc(role_params)

    case Repo.insert(changeset) do
      {:ok, role} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", role_path(conn, :show, role))
        |> render("show.json", role: role)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/roles/:id Get a role
  @apiGroup Roles
  @apiDescription Fetch a single role
  @apiParam {Integer} id    Id of the role
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": {
      "users": [],
      "type": "company",
      "permissions": [
          "read_company",
          "write_company"
      ],
      "id": 2
    }
  }

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    role =
      Repo.get!(Role, id)
      |> Repo.preload(:users)

    render(conn, "show.json", role: role)
  end

  @apidoc """
  @api {PUT} /api/roles/:id Update role
  @apiGroup Roles
  @apiDescription Update role type and permissions
  @apiParam {json} role   Nested JSON object containing below fields 
  @apiParam {String} role.type   Role (admin, student)
  @apiParam {String[]} role.permissions   Permissions for role
  @apiSuccessExample {json} Success
  HTTP 200 OK

  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  @apiUse NotFoundError
  @apiUse BadRequestError

  """
  def update(conn, %{"id" => id, "role" => role_params}) do
    role = Repo.get!(Role, id) |> Repo.preload(:users)

    changeset =
      Role.changeset(role, role_params)
      |> User.put_assoc(role_params)

    case Repo.update(changeset) do
      {:ok, role} ->
        render(conn, "show.json", role: role)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/role/:id Delete role
  @apiGroup Roles
  @apiDescription Completely remove role
  @apiParam {Integer} id    Id of the role
  @apiSuccessExample {json} Success
  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    role = Repo.get!(Role, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(role)

    send_resp(conn, :no_content, "")
  end
end
