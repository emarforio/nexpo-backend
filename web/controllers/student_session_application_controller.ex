defmodule Nexpo.StudentSessionApplicationController do
  use Nexpo.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nexpo.{Student, StudentSessionApplication}

  def create(
        conn,
        %{"student_session_application" => student_session_applications_params},
        user,
        _claims
      ) do
    student = Repo.get_by!(Student, %{user_id: user.id})

    data = Map.put(student_session_applications_params, "student_id", student.id)

    changeset =
      student
      |> Ecto.build_assoc(:student_session_applications)
      |> StudentSessionApplication.changeset(data)

    case Repo.insert(changeset) do
      {:ok, _application} ->
        conn
        |> redirect(to: user_path(conn, :show_me, %{}))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {PUT} /api/me/student_session_applications/:id Update an application
  @apiGroup Student
  @apiDescription  Update an applictaion as student
  @apiParam {json} student_session_application   Nested JSON object containing below fields 
  @apiParam {String}  student_session_application.motivation   Optional, Motivation for application
  @apiParam {Boolean}  student_session_application.company_approved   Optional, If applictation is approved by company
  @apiParam {Integer}  student_session_application.score   Optional, Score of application, judged by company?
  @apiParam {Integer}  student_session_application.company_id   Optional, Id of company
  @apiParam {Integer}  student_session_application.student_id    Optional, Id of student
  @apiSuccessExample {json} Success
  
  HTTP 200 OK

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnprocessableEntity
  """
  #TODO: implement access control, after that check apidoc for this one too
  def update_me(
        conn,
        %{
          "id" => application_id,
          "student_session_application" => student_session_applications_params
        },
        _user,
        _claims
      ) do
    case StudentSessionApplication |> Repo.get(application_id) do
      nil ->
        conn
        |> put_status(400)
        |> render(Nexpo.ErrorView, "400.json")

      application ->
        changeset =
          StudentSessionApplication.changeset(
            application,
            student_session_applications_params
          )

        case Repo.update(changeset) do
          {:ok, appl} ->
            render(conn, "show.json", student_session_application: appl)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
        end
    end
  end

  @apidoc """
  @api {DELETE} /api/me/student_session_applications/:id Delete an application
  @apiGroup Application
  @apiDescription Delete an application that this student made
  @apiParam {Integer} id    Id of the application
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse BadRequestError
  @apiUse NotFoundError
  """
  def delete_me(conn, %{"id" => application_id}, user, _claims) do
    student = Repo.get_by!(Student, %{user_id: user.id})

    case Repo.get_by(StudentSessionApplication, %{id: application_id, student_id: student.id}) do
      nil ->
        conn
        |> put_status(404)
        |> render(Nexpo.ErrorView, "404.json")

      application ->
        Repo.delete!(application)
        send_resp(conn, :no_content, "")
    end
  end
end
