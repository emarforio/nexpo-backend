defmodule Nexpo.MailtemplateController do
  use Nexpo.Web, :controller

  alias Nexpo.Mailtemplate
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
  @api {GET} /api/mailtemplates Get all mailtemplates
  @apiGroup Mailtemplates
  @apiDescription Fetch all available mailtemplates
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    mailtemplates = Repo.all(Mailtemplate)
    render(conn, "index.json", mailtemplates: mailtemplates)
  end

  @apidoc """
  @api {POST} /api/mailtemplates Create a mailtemplate
  @apiGroup Mailtemplates
  @apiDescription Create a mailtemplate
  @apiParam {String}  mailtemplate.name   Name of mailtemplate
  @apiParam {String}  mailtemplate.subject   Subject of mailtemplate
  @apiParam {String}  mailtemplate.content   Content of mailtemplate
  @apiParam {String}  mailtemplate.signature   Optional, mail signature
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "subject": "Arkad Invite",
      "signature": "Tommy Nilsson",
      "name": "Template",
      "id": 5,
      "content": "Yoyo"
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"mailtemplate" => mailtemplate_params}) do
    changeset = Mailtemplate.changeset(%Mailtemplate{}, mailtemplate_params)

    case Repo.insert(changeset) do
      {:ok, mailtemplate} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", mailtemplate_path(conn, :show, mailtemplate))
        |> render("show.json", mailtemplate: mailtemplate)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/mailtemplates/:id Get a mailtemplate
  @apiGroup Mailtemplates
  @apiDescription Fetch a single mailtemplate
  @apiParam {Integer} id    Id of the mailtemplate
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    mailtemplate = Repo.get!(Mailtemplate, id)
    render(conn, "show.json", mailtemplate: mailtemplate)
  end

  @apidoc """
  @api {PUT} /api/mailtemplates/:id Update a mailtemplate
  @apiGroup Mailtemplates
  @apiDescription Update a mailtemplate
  @apiParam {String}  mailtemplate.name   Name of mailtemplate
  @apiParam {String}  mailtemplate.subject   Subject of mailtemplate
  @apiParam {String}  mailtemplate.content   Content of mailtemplate
  @apiParam {String}  mailtemplate.signature   Mail signature
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "mailtemplate" => mailtemplate_params}) do
    mailtemplate = Repo.get!(Mailtemplate, id)
    changeset = Mailtemplate.changeset(mailtemplate, mailtemplate_params)

    case Repo.update(changeset) do
      {:ok, mailtemplate} ->
        render(conn, "show.json", mailtemplate: mailtemplate)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/mailtemplates/:id Delete a mailtemplate
  @apiGroup Mailtemplates
  @apiDescription Completely remove a mailtemplate
  @apiParam {Integer}  id   Id of mailtemplate
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    mailtemplate = Repo.get!(Mailtemplate, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(mailtemplate)

    send_resp(conn, :no_content, "")
  end
end
