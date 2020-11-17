defmodule Nexpo.UserController do
  use Nexpo.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nexpo.{User, ProfileImage, Email, Mailer}
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
    when action in [:update, :delete]
  )
  @apidoc """
  @api {GET} /api/users Get all users
  @apiGroup User
  @apiDescription Fetch all users as admin
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
      {
        "student": {
          "year": null,
          "user_id": 4,
          "student_sessions": [],
          "student_session_applications": [
            {
              "student_id": 3,
              "score": 2,
              "motivation": "",
              "id": 7,
              "company_id": 1
            },
            {
              "student_id": 3,
              "score": 3,
              "motivation": "",
              "id": 8,
              "company_id": 2
            },
            {
              "student_id": 3,
              "score": 4,
              "motivation": "",
              "id": 9,
              "company_id": 3
            }
          ],
          "resume_sv_url": null,
          "resume_en_url": null,
          "programme": null,
          "master": null,
          "linked_in": null,
          "interests": [],
          "id": 3,
          "event_tickets": []
        },
        "roles": [],
        "representative": null,
        "profile_image": null,
        "phone_number": "0708334455",
        "last_name": "Student",
        "id": 4,
        "food_preferences": "",
        "first_name": "Charlie",
        "email": "student3@test.com"
      },
      {
        "student": null,
        "roles": [],
        "representative": {
          "user_id": 5,
          "id": 1,
          "company_id": 1,
          "company": {
            "website": "www.google.com",
            "top_students": [],
            "student_session_days": 1,
            "name": "Google",
            "logo_url": null,
            "id": 1,
            "host_phone_number": null,
            "host_name": null,
            "host_mail": null,
            "description": "We code!"
          }
        },
        "profile_image": null,
        "phone_number": "555123456",
        "last_name": "Company",
        "id": 5,
        "food_preferences": "",
        "first_name": "Alfa",
        "email": "company1@test.com"
      }
    ]
  }

  @apiUse UnauthorizedError
  """
  def index(conn, %{}, _user, _claims) do
    users =
      Repo.all(User)
      |> Repo.preload([
        :roles,
        student: [
          :interests,
          :programme,
          :student_sessions,
          :student_session_applications,
          :event_tickets
        ],
        representative: [:company]
      ])

    render(conn, "index.json", users: users)
  end

  @apidoc """
  @api {GET} /api/users/:id Get a single user
  @apiGroup User
  @apiDescription Fetch a single user as admin
  @apiParam {Integer} id    Id of the user
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": {
      "student": null,
      "roles": [],
      "representative": {
        "user_id": 7,
        "id": 3,
        "company_id": 3,
        "company": {
          "website": "www.intel.com",
          "top_students": [],
          "student_session_days": 3,
          "name": "Intel",
          "logo_url": null,
          "id": 3,
          "host_phone_number": null,
          "host_name": null,
          "host_mail": null,
          "description": "We do stuff!"
        }
      },
      "profile_image": null,
      "phone_number": "555123456",
      "last_name": "Company",
      "id": 7,
      "food_preferences": "",
      "first_name": "Charlie",
      "email": "company3@test.com"
    }
  }

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}, _user, _claims) do
    user =
      Repo.get!(User, id)
      |> Repo.preload([
        :roles,
        student: [
          :interests,
          :programme,
          :student_sessions,
          :student_session_applications,
          :event_tickets
        ],
        representative: [:company]
      ])

    render(conn, "show.json", user: user)
  end

  #todo this doc
  @apidoc """
  @api {PUT} api/users Update company website and description
  @apiGroup User
  @apiDescription As a representative, update company website and description
  @apiParam {json} company   Nested JSON object containing below fields 
  @apiParam {String} company.description   Description of company
  @apiParam {String} company.website   Company URL
  @apiSuccessExample {json} Success
  HTTP 200 OK

  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  @apiUse NotFoundError
  @apiUse BadRequestError

  """
  def update(conn, %{"id" => id, "user" => user_params}, _user, _claims) do
    user =
      Repo.get!(User, id)
      |> Repo.preload([
        :roles,
        student: [
          :interests,
          :programme,
          :student_sessions,
          :student_session_applications,
          :event_tickets
        ]
      ])

    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/users/:id Delete a user
  @apiGroup Events
  @apiDescription Remove a user as admin
  @apiParam {Integer} id    Id of the user to be deleted
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse NotFoundError
  """
  def delete(conn, %{"id" => id}, _user, _claims) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  @apidoc """
  @api {GET} api/me Request user information

  @apiGroup User

  @apiSuccessExample {json} Success
    HTTP 200 OK
    {
      "data": {
        "student": {
          "year": null,
          "user_id": 2,
          "student_sessions": [
            {
              "student_session_time_slot": {
                "start": "2000-01-01T08:00:00.000000",
                "location": "Albatraoz",
                "id": 1,
                "end": "2000-01-01T08:15:00.000000"
              },
              "student_session_status": 1,
              "student_id": 1,
              "id": 1,
              "company_id": 1,
              "company": {
                "website": "www.google.com",
                "top_students": [],
                "student_session_days": 1,
                "name": "Google",
                "logo_url": null,
                "id": 1,
                "host_phone_number": null,
                "host_name": null,
                "host_mail": null,
                "description": "We code!"
              }
            }
          ],
          "student_session_applications": [
            {
              "student_id": 1,
              "score": 5,
              "motivation": "",
              "id": 1,
              "company_id": 1,
              "company": {
                "website": "www.google.com",
                "top_students": [],
                "student_session_days": 1,
                "name": "Google",
                "logo_url": null,
                "id": 1,
                "host_phone_number": null,
                "host_name": null,
                "host_mail": null,
                "description": "We code!"
              }
            }
          ],
          "resume_sv_url": null,
          "resume_en_url": null,
          "programme": null,
          "master": null,
          "linked_in": null,
          "interests": [],
          "id": 1,
          "event_tickets": [
            {
              "ticket_code": "$2b$04$AL20RQhngqq.m8risJDwYOYrwOkyWPeDAV5FTJlYlErhxUgphTnlW",
              "photo": true,
              "id": 1,
              "event_id": 1
            }
          ]
        },
        "roles": [],
        "representative": null,
        "profile_image": null,
        "phone_number": "0708334455",
        "last_name": "Student",
        "id": 2,
        "food_preferences": "",
        "first_name": "Alfa",
        "email": "student1@test.com"
      }
  }

  @apiUse BadRequestError
  """
  def show_me(conn, %{}, user, _claims) do
    user =
      Repo.preload(user, [
        :roles,
        student: [
          :programme,
          :interests,
          :event_tickets,
          student_sessions: [:company, :student_session_time_slot],
          student_session_applications: :company
        ],
        representative: [company: [student_sessions: [:student, :student_session_time_slot]]]
      ])

    conn |> put_status(200) |> render("show.json", user: user)
  end

  @apidoc """
  @api {POST} api/me Update user information
  @apiGroup User
  @apiParam {json} User Same structure as information recieved when requesting information
  @apiSuccessExample {json} Success
    HTTP 200 OK
  @apiUse BadRequestError
  """
  def update_me(conn, %{"user" => user_params}, user, _claims) do
    changeset = User.changeset(user, user_params)

    Map.keys(user_params)
    |> Enum.filter(fn k -> k in ["profile_image"] end)
    |> Enum.each(fn k ->
      delete_file?(user, user_params, String.to_atom(k))
    end)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, "show.json", user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} api/me Delete user
  @apiGroup User
  @apiSuccessExample {json} Success
    HTTP 200 OK
  @apiUse BadRequestError
  """
  def delete_me(conn, %{}, user, _claims) do
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  @apidoc """
  @api {POST} api/password/forgot Init reset of password
  @apiGroup Forgot password

  @apiParam {String}  email   Email of user

  @apiSuccessExample {json} Success
    HTTP 200 OK
    {
      "type": "message",
      "data": "Sending email if user exists"
    }

  @apiUse BadRequestError
  """
  def forgot_password_init(conn, %{"email" => email}, _user, _claims) do
    user = Repo.get_by(User, email: email |> String.downcase())

    if user != nil and user.hashed_password != nil do
      user = User.forgot_password_changeset(user) |> Repo.update!()
      Email.reset_password(user) |> Mailer.deliver_later()
    end

    conn
    |> put_status(200)
    |> render(Nexpo.MessageView, "message.json", message: "Sending mail if user exists")
  end

  @apidoc """
  @api {POST} api/password/new/:key Reset forgotten password
  @apiGroup Forgot password

  @apiParam {String}  key                   Key representing this password reset
  @apiParam {String}  password              New password
  @apiParam {String}  password_confirmation Confirmation of password

  @apiSuccessExample {json} Success
    HTTP 200 OK
    {
      "type": "message",
      "data": "Successfully changed password"
    }

  @apiUse NotFoundError
  @apiUse BadRequestError
  """
  def replace_forgotten_password(
        conn,
        %{"password" => password, "password_confirmation" => password_confirmation, "key" => key},
        _user,
        _claims
      ) do
    case Repo.get_by(User, forgot_password_key: key) do
      nil ->
        replace_forgotten_password(conn, nil, nil, nil)

      user ->
        case User.forgot_password_key_valid(user) do
          true ->
            params = %{
              password: password,
              password_confirmation: password_confirmation
            }

            changeset = User.replace_forgotten_password_changeset(user, params)

            case Repo.update(changeset) do
              {:ok, _user} ->
                conn
                |> put_status(200)
                |> render(Nexpo.MessageView, "message.json",
                  message: "Successfully changed password"
                )

              {:error, changeset} ->
                conn
                |> put_status(400)
                |> render(Nexpo.ChangesetView, "error.json", %{changeset: changeset})
            end

          false ->
            replace_forgotten_password(conn, nil, nil, nil)
        end
    end
  end

  def replace_forgotten_password(conn, _params, _user, _claims) do
    conn |> put_status(404) |> render(Nexpo.ErrorView, "404.json")
  end

  @apidoc """
  @api {GET} api/password/forgot/:key Verify password forgotten
  @apiGroup Forgot password

  @apiParam {String}  key   Key representing a password reset

  @apiSuccessExample {json} Success
    HTTP 200 OK
    {
      "type": "message",
      "data": "Exists"
    }

  @apiUse NotFoundError
  @apiUse BadRequestError
  """
  def forgot_password_verification(conn, %{"key" => key}, _user, _claims) do
    case Repo.get_by(User, forgot_password_key: key) do
      nil ->
        forgot_password_verification(conn, nil, nil, nil)

      user ->
        case User.forgot_password_key_valid(user) do
          true ->
            conn
            |> put_status(200)
            |> render(Nexpo.MessageView, "message.json", message: "Exists")

          false ->
            forgot_password_verification(conn, nil, nil, nil)
        end
    end
  end

  def forgot_password_verification(conn, _, _, _) do
    conn |> put_status(404) |> render(Nexpo.ErrorView, "404.json")
  end

  defp delete_file?(model, params, attr) do
    case Map.get(model, attr) do
      nil -> nil
      existing_file -> delete_file!(model, params, attr, existing_file)
    end
  end

  defp delete_file!(model, params, attr, file) do
    case Map.get(params, Atom.to_string(attr)) do
      nil ->
        case attr do
          :profile_image -> ProfileImage.delete({file, model})
        end

      _ ->
        nil
    end
  end

  @apidoc
end
