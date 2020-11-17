defmodule Nexpo.CompanyController do
  use Nexpo.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nexpo.{Company, Representative, User}
  alias Nexpo.{Email, Mailer}
  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}, %{default: ["read_companies"]}]
    ]
    when action in [:show]
  )

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["write_all"]}, %{default: ["write_companies"]}]
    ]
    when action in [:create, :update, :delete, :create_bulk]
  )

  @apidoc """
  @api {GET} /companies List companies
  @apiGroup Company
  @apiSuccessExample {json} Success
    HTTP 200 Ok
    {
      "data": [
        {
          "id": 1,
          "name": "CodeComp",
          "description": "We do code!"
        },
        {
          "id": 2,
          "name": "Other Comp",
          "description": "We do other things!"
        }
      ]
    }
  @apiUse InternalServerError
  """
  def index(conn, _params, _user, _claims) do
    companies = Repo.all(Company)
    render(conn, "index.json", companies: companies)
  end

  @apidoc """
  @api {POST} /api/companies Create a company
  @apiGroup Company
  @apiDescription Create a company 
  @apiParam {json} company   Nested JSON object containing below fields 
  @apiParam {String} company.name   Name of company
  @apiParam {String} company.description   Description of company
  @apiParam {String} company.website   URL of company
  @apiParam {Integer} company.student_session_days   Optional, Days of student sessions
  @apiParam {Integer} company.host_name   Optional, Name of host
  @apiParam {Integer} company.host_mail   Optional, Mail of host
  @apiParam {Integer} company.host_phone_number   Optional, Phone number of host
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "website": "hello",
      "top_students": [],
      "student_session_days": 0,
      "name": "brofist",
      "logo_url": null,
      "id": 6,
      "host_phone_number": null,
      "host_name": null,
      "host_mail": null,
      "description": "we do this here"
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"company" => company_params}, _user, _claims) do
    changeset = Company.changeset(%Company{}, company_params)

    case Repo.insert(changeset) do
      {:ok, company} ->
        conn
        |> put_status(:created)
        |> render("show.json", company: company)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {POST} /api/companies/create_bulk Create companies and representatives
  @apiGroup Company
  @apiDescription Create companies and associated representatives in bulk
  @apiParam {json} companies   Nested JSON object containing multiple company_params 
  @apiParam {String} companies.company1.name   Name of company1
  @apiParam {String} companies.company1.description   Description of company
  @apiParam {String} companies.company1.website   URL of company
  @apiParam {Integer} companies.company1.student_session_days   Optional, Days of student sessions
  @apiParam {Integer} companies.company1.host_name   Optional, Name of host
  @apiParam {Integer} companies.company1.host_mail   Optional, Mail of host
  @apiParam {Integer} companies.company1.host_phone_number   Optional, Phone number of host

  @apiParam {json} representatives   Nested JSON object containing multiple representative_params
  @apiParam {Integer} representatives.representative1.user_id User id
  @apiParam {Integer} representatives.representative1.company_id Company id
  @apiSuccessExample {json} Success

  HTTP 201 Created

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create_bulk(
        conn,
        %{"companies" => companies_params, "representatives" => representatives_params},
        _user,
        _claims
      ) do
    companies_changeset =
      companies_params
      |> Enum.map(fn params -> Company.changeset(%Company{}, params) end)

    representatives_changeset =
      representatives_params
      |> Enum.map(fn params ->
        User.initial_signup_changeset(%User{}, params)
      end)

    Enum.concat(companies_changeset, representatives_changeset)
    |> Enum.filter(&(!&1.valid?))

    case Enum.concat(companies_changeset, representatives_changeset)
         |> Enum.with_index()
         |> Enum.reduce(Ecto.Multi.new(), fn {changeset, index}, multi ->
           Ecto.Multi.insert(multi, Integer.to_string(index), changeset)
         end)
         |> Repo.transaction() do
      {:ok, companies_and_representatives} ->
        companies =
          companies_and_representatives
          |> Map.values()
          |> Enum.filter(fn
            %Company{} -> true
            _ -> false
          end)

        representatives =
          companies_and_representatives
          |> Map.values()
          |> Enum.filter(fn
            %User{} -> true
            _ -> false
          end)

        representatives_params
        |> Enum.each(fn params ->
          user = representatives |> Enum.find(&(&1.email == Map.get(params, "email")))
          company = companies |> Enum.find(&(&1.name == Map.get(params, "name")))

          user |> Email.pre_signup_representative_email(company) |> Mailer.deliver_later()
          Representative.build_assoc!(user, company.id)
        end)

        conn
        |> put_status(:created)
        |> render("index.json", companies: companies)

      {:error, _index, changeset, _company} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /companies/:id Get company
  @apiGroup Company
  @apiParam {Number} id ID of the company
  @apiSuccessExample {json} Success
    HTTP 200 Ok
    {
      "data": {
        "id": 1,
        "name": "CodeComp"
      }
    }

  @apiUse NotFoundError
  @apiUse InternalServerError
  """
  def show(conn, %{"id" => id}, _user, _claims) do
    company =
      Repo.get!(Company, id)
      |> Repo.preload([:users, :entries, :desired_programmes])
      |> Repo.preload([
        :student_session_applications,
        student_session_time_slots: [
          student_session: [student: [:user]]
        ]
      ])
      |> append_top_students

    render(conn, "show.json", company: company)
  end

  defp append_top_students(company) do
    query =
      Repo.all(
        from(appl in Ecto.assoc(company, :student_session_applications),
          join: student in assoc(appl, :student),
          join: user in assoc(student, :user),
          where: not is_nil(appl.score) and appl.score > 0,
          order_by: [desc: appl.score, asc: student.id],
          # Check that student does not already have session with given company
          left_join: co_session in Nexpo.StudentSession,
          on: student.id == co_session.student_id and co_session.company_id == ^company.id,
          where: is_nil(co_session.id),
          select: %{id: student.id, first_name: user.first_name, last_name: user.last_name}
        )
      )

    %{company | top_students: query}
  end

  @apidoc """
  @api {PUT} /api/companies/:id Update a company
  @apiGroup Companies
  @apiDescription Update a company
  @apiParam {json} company   Nested JSON object containing below fields 
  @apiParam {String} company.name   Optional, Name of company
  @apiParam {String} company.description   Optional, Description of company
  @apiParam {String} company.website   Optional, URL of company
  @apiParam {Integer} company.student_session_days   Optional, Days of student sessions
  @apiParam {Integer} company.host_name   Optional, Name of host
  @apiParam {Integer} company.host_mail   Optional, Mail of host
  @apiParam {Integer} company.host_phone_number   Optional, Phone number of host
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "company" => company_params}, _user, _claims) do
    company = Repo.get!(Company, id) |> Repo.preload(:student_session_time_slots)

    # We need to set "null" to nil, since FormData can't send null values
    null_params =
      company_params
      |> Enum.filter(fn {_k, v} -> v == "null" end)
      |> Enum.map(fn {k, _v} -> {k, nil} end)
      |> Map.new()

    company_params = Map.merge(company_params, null_params)
    changeset = Company.changeset(company, company_params)

    Map.keys(company_params)
    |> Enum.filter(fn k -> k in ["logo_url"] end)
    |> Enum.each(fn k ->
      delete_file?(company, company_params, String.to_atom(k))
    end)

    case Repo.update(changeset) do
      {:ok, company} ->
        render(conn, "show.json", company: company)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/companies/:id Delete a company
  @apiGroup Companies
  @apiDescription Completely remove a company
  @apiParam {Integer} id    Id of the company
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}, _user, _claims) do
    company = Repo.get!(Company, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(company)

    send_resp(conn, :no_content, "")
  end

  @apidoc """
  @api {GET} /me/company Get company and related information
  @apiGroup Company
  @apiDescription As a representative, get company information, student applications and more
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError
  """
  def show_me(conn, %{}, user, _claims) do
    representative = Repo.get_by!(Representative, %{user_id: user.id})

    company =
      Ecto.assoc(representative, :company)
      |> Repo.one()
      |> Repo.preload([
        :industries,
        :job_offers,
        :users,
        :entries,
        :representatives,
        :desired_programmes,
        blips: [student: [:user, :interests]],
        student_sessions: [student: :user],
        student_session_applications: [student: [:user, :programme, :interests]],
        student_session_time_slots: [
          student_session: [student: [:user]]
        ]
      ])

    conn |> put_status(200) |> render("show.json", company: company)
  end

  @apidoc """
  @api {PUT} /me/company Update company website and description
  @apiGroup Company
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
  def update_me(conn, %{"company" => company_params}, user, _claims) do
    representative = Repo.get_by!(Representative, %{user_id: user.id})

    company =
      Ecto.assoc(representative, :company)
      |> Repo.one()
      |> Repo.preload([
        :industries,
        :job_offers,
        :users,
        :entries,
        :representatives,
        :desired_programmes,
        blips: [student: [:user, :interests]],
        student_sessions: [student: :user],
        student_session_applications: [student: [:user, :programme, :interests]],
        student_session_time_slots: [
          student_session: [student: [:user]]
        ]
      ])

    # We need to set "null" to nil, since FormData can't send null values
    null_params =
      company_params
      |> Enum.filter(fn {_k, v} -> v == "null" end)
      |> Enum.map(fn {k, _v} -> {k, nil} end)
      |> Map.new()

    company_params = Map.merge(company_params, null_params)
    changeset = Company.representative_changeset(company, company_params)

    Map.keys(company_params)
    |> Enum.filter(fn k -> k in ["logo_url"] end)
    |> Enum.each(fn k ->
      delete_file?(company, company_params, String.to_atom(k))
    end)

    case Repo.update(changeset) do
      {:ok, company} ->
        render(conn, "show.json", company: company)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /me/company Delete company completely
  @apiGroup Company
  @apiDescription As a representative, delete company
  @apiSuccessExample {json} Success
  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete_me(conn, %{}, user, _claims) do
    representative = Repo.get_by!(Representative, %{user_id: user.id})
    company = Ecto.assoc(representative, :company)

    Repo.delete!(company)

    send_resp(conn, :no_content, "")
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
          :logo_url -> Nexpo.CompanyLogo.delete({file, model})
        end

      _ ->
        nil
    end
  end

  @apidoc
end
