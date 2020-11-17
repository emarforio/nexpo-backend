defmodule Nexpo.StudentController do
  use Nexpo.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nexpo.{Student, Programme, Interest}
  alias Nexpo.{CvSv, CvEn}
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
  @api {GET} /api/students Get all students
  @apiGroup Students
  @apiDescription Fetch all available Students
  @apiSuccessExample {json} Success

  HTTP 200 OK
  @apiUse UnauthorizedError
  """
  def index(conn, %{}, _user, _claims) do
    students =
      Repo.all(Student)
      |> Repo.preload([
        :interests,
        :programme,
        :student_sessions,
        :student_session_applications,
        :event_tickets
      ])

    render(conn, "index.json", students: students)
  end

  @apidoc """
  @api {POST} /api/students Create a student
  @apiGroup Students
  @apiDescription Create a student 
  @apiParam {json} student   Nested JSON object containing below fields 
  @apiParam {Integer}  student.year   Optional, Enrollment year
  @apiParam {String}  student.master   Optional, Programme (C, D, E etc.)
  @apiParam {String}  student.linked_in   Optional, LinkedIn link
  @apiParam {String[]} student.interests   Optional, Student interests
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "year": 3,
      "user_id": 10,
      "resume_sv_url": null,
      "resume_en_url": null,
      "master": "D",
      "linked_in": "No",
      "interests": [],
      "id": 6
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"student" => student_params}, _user, _claims) do
    changeset = Student.changeset(%Student{}, student_params)

    case Repo.insert(changeset) do
      {:ok, student} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", student_path(conn, :show, student))
        |> render("show.json", student: student |> Repo.preload(:interests))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/students/:id Get a student
  @apiGroup Students
  @apiDescription Fetch a single student
  @apiParam {Integer} id    Id of the student
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}, _user, _claims) do
    student =
      Student
      |> Repo.get!(id)
      |> Repo.preload([
        :interests,
        :programme,
        :student_sessions,
        :student_session_applications,
        :event_tickets
      ])

    render(conn, "show.json", student: student)
  end

  @apidoc """
  @api {PUT} /api/me/student Update info
  @apiGroup Student
  @apiDescription  Update student info
  @apiParam {json} student   Nested JSON object containing below fields 
  @apiParam {Integer}  student.year   Optional, Enrollment year
  @apiParam {String}  student.master   Optional, Programme (C, D, E etc.)
  @apiParam {String}  student.linked_in   Optional, LinkedIn link
  @apiParam {String}  student.resume_en_url   Optional, Resume in english link
  @apiParam {String}  student.resume_sv_url   Optional, Resume in swedish link
  @apiSuccessExample {json} Success
  
  HTTP 200 OK
  
  @apiUse BadRequestError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "student" => student_params}, _user, _claims) do
    student =
      Repo.get!(Student, id)
      |> Repo.preload([:interests, :programme])

    changeset = Student.changeset(student, student_params)

    case Repo.update(changeset) do
      {:ok, student} ->
        render(conn, "show.json", student: student)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {PUT} /api/me/student Update info
  @apiGroup Student
  @apiDescription  Update your own info as student
  @apiParam {json} student   Nested JSON object containing below fields 
  @apiParam {Integer}  student.year   Optional, Enrollment year
  @apiParam {String}  student.master   Optional, Programme (C, D, E etc.)
  @apiParam {String}  student.linked_in   Optional, LinkedIn link
  @apiParam {String}  student.resume_en_url   Optional, Resume in english link
  @apiParam {String}  student.resume_sv_url   Optional, Resume in swedish link
  @apiSuccessExample {json} Success
  
  HTTP 200 OK
  
  @apiUse BadRequestError
  @apiUse UnprocessableEntity
  """
  def update_student(conn, %{"student" => student_params}, user, _claims) do
    student =
      Repo.get_by!(Student, %{user_id: user.id})
      |> Repo.preload([:programme, :interests])

    # We need to set "null" to nil, since FormData can't send null values
    null_params =
      student_params
      |> Enum.filter(fn {_k, v} -> v == "null" end)
      |> Enum.map(fn {k, _v} -> {k, nil} end)
      |> Map.new()

    student_params = Map.merge(student_params, null_params)

    changeset =
      Student.changeset(student, student_params)
      |> Programme.put_assoc(student_params)
      |> Interest.put_assoc(student_params)

    Map.keys(student_params)
    |> Enum.filter(fn k -> k in ["resume_sv_url", "resume_en_url"] end)
    |> Enum.each(fn k ->
      delete_file?(student, student_params, String.to_atom(k))
    end)

    case Repo.update(changeset) do
      {:ok, student} ->
        render(conn, "show.json", student: student)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/students/:id Delete a student
  @apiGroup Roles
  @apiDescription Completely remove a student
  @apiParam {Integer} id    Id of the student
  @apiSuccessExample {json} Success
  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}, _user, _claims) do
    student = Repo.get!(Student, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(student)

    send_resp(conn, :no_content, "")
  end

  defp delete_file?(model, params, attr) do
    case Map.get(model, attr) do
      nil -> nil
      existing_cv -> delete_file!(model, params, attr, existing_cv)
    end
  end

  defp delete_file!(model, params, attr, file) do
    case Map.get(params, Atom.to_string(attr)) do
      nil ->
        case attr do
          :resume_sv_url -> CvSv.delete({file, model})
          :resume_en_url -> CvEn.delete({file, model})
        end

      _ ->
        nil
    end
  end
end
