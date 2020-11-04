defmodule Nexpo.BlipController do
  use Nexpo.Web, :controller
  # I denna version av phoenix lägger denna raden till User och "claims" till varje request
  use Guardian.Phoenix.Controller
  import Ecto.Query
  alias Nexpo.Blip

  @apidoc """
  @api {GET} /api/me/company/blips List blips
  @apiGroup Blips
  @apiDescription List all students that have blipd by your booth
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
        {
          "year": null,
          "student_id": 3,
          "resume_sv_url": null,
          "resume_en_url": null,
          "rating": 4,
          "programme": null,
          "profile_image": null,
          "master": null,
          "linked_in": null,
          "last_name": "Student",
          "interests": [],
          "inserted_at": "2020-10-24T14:44:18.430950",
          "first_name": "Charlie",
          "email": "student3@test.com",
          "comment": "who dis?"
        }
    ]
  }

  @apiUse ForbiddenError
  """
  def index(conn, _params, user, _claims) do
    representative =
      user
      |> Repo.preload(:representative)
      |> Map.get(:representative)

    case representative do
      nil ->
        send_resp(conn, :forbidden, "")

      representative ->
        company_id = representative.company_id

        blips =
          from(b in Blip,
            where: b.company_id == ^company_id
          )
          |> order_by(desc: :inserted_at)
          |> Repo.all()
          |> Repo.preload([
            [student: [:interests, :user, :programme]]
          ])
          |> Enum.map(fn blip ->
            blip
            |> Map.merge(blip.student)
            |> Map.merge(blip.student.user)
            |> Map.put(:blipped_at, blip.inserted_at)
            |> Map.drop([:user])
          end)

        render(conn, "index.json", blips: blips)
    end
  end

  @apidoc """
  @api {POST} /api/me/company/blips Create a blip for student
  @apiGroup Blips
  @apiDescription Create/ a comment of a student that has blipped your company

  @apiParam {Integer} student_id    Id of student blips
  @apiParam {Integer} rating    Optional, rating between 1 and five
  @apiParam {String}  comment   Optional, Your thoughts about the student
  @apiParamExample {json} Request-Example:
                 { "student_id": 1}

  @apiSuccessExample {json} Success
  HTTP 200 OK
  {
    "data": {
      "student": {
        "year": null,
        "user_id": 4,
        "resume_sv_url": null,
        "resume_en_url": null,
        "master": null,
        "linked_in": null,
        "id": 3
      },
      "rating": 2,
      "id": 9,
      "company_id": 1,
      "comment": "haha"
    }
  }

  @apiUse UnprocessableEntity
  @apiUse ForbiddenError
  @apiUse BadRequestError
  """
  def create(conn, blip_params, user, _claims) do
    user
    |> Repo.preload(:representative)
    |> Map.get(:representative)
    |> case do
      %{company_id: company_id} ->
        blip_params = Map.put(blip_params, "company_id", company_id)

        %Blip{}
        |> Blip.changeset(blip_params)
        |> Repo.insert()
        |> case do
          {:ok, blip} ->
            blip = Repo.preload(blip, [:student])
            blip = Map.put(blip, "company_id", company_id)

            conn
            |> put_status(:created)
            |> render("show.json", blip: blip)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
        end

      nil ->
        send_resp(conn, :forbidden, "")
    end
  end

  @apidoc """
  @api {GET} /api/me/company/blips/:student_id Student Info & blip data
  @apiGroup Blips
  @apiDescription Gets information about a student and your comments about them
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "year": null,
    "student_id": 3,
    "resume_sv_url": null,
    "resume_en_url": null,
    "rating": 4,
    "programme": null,
    "profile_image": null,
    "master": null,
    "linked_in": null,
    "last_name": "Student",
    "interests": [],
    "inserted_at": "2020-10-24T14:44:18.430950",
    "first_name": "Charlie",
    "email": "student3@test.com",
    "comment": "who dis?"
  }

  @apiUse NotFoundError
  @apiUse BadRequestError
  """
  def show(conn, %{"id" => student_id}, user, _claims) do
    user
    |> get_blip(student_id)
    |> Repo.preload([
      [student: [:interests, :user, :programme]]
    ])

    case user do
      nil ->
        send_resp(conn, :not_found, "")

      blip = %{} ->
        blip =
          blip
          |> Map.merge(blip.student)
          |> Map.merge(blip.student.user)
          |> Map.put(:blipped_at, blip.inserted_at)
          |> Map.drop([:user])

        render(conn, "student.json", blip: blip)
    end
  end

  @apidoc """
  @api {PATCH} /api/me/company/blips/:student_id Update blip info
  @apiGroup Blips
  @apiDescription Update the comment or rating of a student scanned by this company
  @apiParam {Integer} rating    The new rating in JSON body
  @apiParam {String} comment     The new comment in JSON body
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": {
      "rating": 2,
      "id": 3,
      "comment": "haha"
    }
  }

  @apiUse UnprocessableEntity
  @apiUse BadRequestError
  """
  def update(conn, %{"id" => student_id} = blip_params, user, _claims) do
    user
    |> get_blip(student_id)
    |> Blip.changeset(%{rating: blip_params.rating, comment: blip_params.comment})
    |> Repo.update()
    |> case do
      {:ok, blip} ->
        render(conn, "show.json", blip: blip)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/me/company/blips/:student_id Unblip - Delete a blip
  @apiGroup Blips
  @apiDescription Delete comment, rating and the blip itself from a student who blipped your company
  @apiParam {Integer} student_id    The id of the student
  @apiSuccessExample {json} Success
  HTTP 204 NoContent
  (empty resp)

  @apiUse NotFoundError
  @apiUse BadRequestError
  """
  def delete(conn, %{"id" => student_id}, user, _claims) do
    blip = get_blip(user, student_id)

    case blip do
      nil ->
        send_resp(conn, :not_found, "")

      blip ->
        case Repo.delete(blip) do
          {:ok, struct} ->
            send_resp(conn, :no_content, "")

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
        end
    end
  end

  defp company_id(user) do
    user
    |> Repo.preload(:representative)
    |> Map.get(:representative)
    |> Map.get(:company_id)
  end

  defp get_blip(user, student_id) do
    company_id = company_id(user)

    from(b in Blip,
      where: b.company_id == ^company_id and b.student_id == ^student_id
    )
    |> Repo.one()
  end

  @apidoc
end
