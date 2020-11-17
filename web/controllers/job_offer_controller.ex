defmodule Nexpo.JobOfferController do
  use Nexpo.Web, :controller

  alias Nexpo.JobOffer
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
    when action in [:create, :update, :delete]
  )

  @apidoc """
  @api {GET} /api/job_offers Get all job offers
  @apiGroup Job Offers
  @apiDescription Fetch all available job offers
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse UnauthorizedError
  """
  def index(conn, _params) do
    job_offers = Repo.all(JobOffer)
    render(conn, "index.json", job_offers: job_offers)
  end

  @apidoc """
  @api {POST} /api/job_offers Create a job offer
  @apiGroup Job Offers
  @apiDescription Create a job offer 
  @apiParam {String}  job_offer.type   Type of job offer
  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": {
      "type": "Job",
      "id": 1
    }
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def create(conn, %{"job_offer" => job_offer_params}) do
    changeset = JobOffer.changeset(%JobOffer{}, job_offer_params)

    case Repo.insert(changeset) do
      {:ok, job_offer} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", job_offer_path(conn, :show, job_offer))
        |> render("show.json", job_offer: job_offer)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {GET} /api/job_offers/:id Get a job offer
  @apiGroup Job Offers
  @apiDescription Fetch a single job offer
  @apiParam {Integer} id    Id of the job offer
  @apiSuccessExample {json} Success

  HTTP 200 OK
 

  @apiUse NotFoundError
  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def show(conn, %{"id" => id}) do
    job_offer = Repo.get!(JobOffer, id)
    render(conn, "show.json", job_offer: job_offer)
  end

  @apidoc """
  @api {PUT} /api/job_offers/:id Update a job offer
  @apiGroup Job Offer
  @apiDescription Update a job offer
  @apiParam {Integer}  id   Id of job offer
  @apiParam {String}  job_offer.type   Type of industry
  @apiSuccessExample {json} Success

  HTTP 200 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  """
  def update(conn, %{"id" => id, "job_offer" => job_offer_params}) do
    job_offer = Repo.get!(JobOffer, id)
    changeset = JobOffer.changeset(job_offer, job_offer_params)

    case Repo.update(changeset) do
      {:ok, job_offer} ->
        render(conn, "show.json", job_offer: job_offer)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
    end
  end

  @apidoc """
  @api {DELETE} /api/job_offer/:id Delete a job offer
  @apiGroup Job Offer
  @apiDescription Completely remove a job offer
  @apiParam {Integer}  id   Id of job offer
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse UnauthorizedError
  @apiUse NotFoundError

  """
  def delete(conn, %{"id" => id}) do
    job_offer = Repo.get!(JobOffer, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(job_offer)

    send_resp(conn, :no_content, "")
  end
end
