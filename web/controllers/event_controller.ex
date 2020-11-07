defmodule Nexpo.EventController do
  use Nexpo.Web, :controller
  # user kommer från Guardian
  use Guardian.Phoenix.Controller

  alias Nexpo.Event
  alias Nexpo.EventTicket

  alias Guardian.Plug.{EnsurePermissions}

  plug(
    EnsurePermissions,
    [
      handler: Nexpo.SessionController,
      one_of: [%{default: ["read_all"]}]
    ]
    when action in [:get_all_tickets]
  )

  @apidoc """
  @api {GET} /api/events Get all events
  @apiGroup Events
  @apiDescription Fetch all available events
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
      {
        "start": "15:10",
        "name": "Bounce",
        "location": "Outside Kårhuset, bus to Malmö",
        "id": 1,
        "end": "17:30",
        "date": "Nov 3rd - Sunday"
      },
      {
        "start": "17:15",
        "name": "The digital shift - how will you be affected?",
        "location": "Kårhuset: Auditorium",
        "id": 2,
        "end": "18:45",
        "date": "Nov 4rd - Monday"
      }
    ]
  }

  """
  def index(conn, %{}, _user, _claims) do
    events = Repo.all(Event)

    render(conn, "index.json", events: events)
  end

  @apidoc """
  @api {GET} /api/event/:id Get an event
  @apiGroup Events
  @apiDescription Fetch a single event
  @apiParam {Integer} id    Id of the event
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": {
      "tickets_left": 19,
      "start": "15:10",
      "name": "Bounce",
      "location": "Outside Kårhuset, bus to Malmö",
      "id": 1,
      "event_info": {
        "tickets": 20,
        "language": null,
        "id": 1,
        "host": null,
        "description": "Placeholder"
      },
      "end": "17:30",
      "date": "Nov 3rd - Sunday"
    }
  }

  @apiUse NotFoundError
  @apiUse BadRequestError
  """
  def get_event(conn, %{"id" => event_id}, _user, _claims) do
    event =
      Repo.get!(Event, event_id)
      |> Repo.preload([:event_info, :event_tickets])

    tickets_left = event.event_info.tickets - Enum.count(event.event_tickets)

    event =
      Map.delete(event, :event_tickets)
      |> Map.merge(%{
        tickets_left: tickets_left
      })

    case event do
      nil ->
        conn
        |> put_status(404)
        |> render(Nexpo.ErrorView, "404.json")

      event ->
        render(conn, "show.json", event: event)
    end
  end

  @apidoc """
  @api {GET} /api/event/tickets Get tickets
  @apiGroup Events
  @apiDescription Fetch all tickets for this student
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
      {
        "ticket_code": "$2b$04$WbQloXKuTH02YJ4bqzuPCOcFakIKwXJI74Wce.jJsBq7RJHqsn6g.",
        "photo": null,
        "id": 1,
        "event_id": 1
      }
    ]
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  """
  def get_tickets(conn, %{}, user, _claims) do
    user_student =
      user
      |> Repo.preload([:student])

    case user_student.student do
      nil ->
        conn
        |> put_status(401)
        |> render(Nexpo.ErrorView, "401.json")

      student ->
        student_tickets =
          student
          |> Repo.preload([:event_tickets])

        render(conn, Nexpo.EventTicketView, "index.json",
          event_tickets: student_tickets.event_tickets
        )
    end
  end

  @apidoc """
  @api {GET} /api/admin/event/tickets Get all event tickets
  @apiGroup Events
  @apiDescription Fetch all event tickets as admin
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": [
      {
        "ticket_code": "$2b$04$ma5/mqWtDmFJqF2jds3.o.esB5UNBYv7t4ZPwwkbHe5tABYdhWm0C",
        "photo": true,
        "id": 35,
        "event_id": 1
      },
      {
        "ticket_code": "$2b$04$8fvB3uOgGfxWyBkihEJyW.hsN6YtJJ5ohxc28dg3B4QOuLSelTpLm",
        "photo": false,
        "id": 36,
        "event_id": 2
      }
    ]
  }

  @apiUse UnauthorizedError
  """
  def get_all_tickets(conn, %{}, _user, _claims) do
    tickets = Repo.all(EventTicket)

    render(conn, Nexpo.EventTicketView, "index.json", event_tickets: tickets)
  end

  @apidoc """
  @api {PUT} /api/event/ticket Create ticket
  @apiGroup Events
  @apiDescription Create a ticket for this student
  @apiParam {Integer} event_id    Id of event
  @apiParam {Boolean} photo    If student allows taking photos of themselves
  @apiParamExample {json} Request-Example:
                 { 
                   "event_id": 1
                   "photo": true
                 }

  @apiSuccessExample {json} Success

  HTTP 201 Created
  {
    "data": [
      {
        "ticket_code": "$2b$04$WbQloXKuTH02YJ4bqzuPCOcFakIKwXJI74Wce.jJsBq7RJHqsn6g.",
        "photo": true,
        "id": 1,
        "event_id": 1
      }
    ]
  }

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse UnprocessableEntity
  @apiUse NotFoundError
  """
  def create_ticket(conn, %{"event_id" => event_id, "photo" => photo}, user, _claims) do
    user_student =
      user
      |> Repo.preload([:student])

    case user_student.student do
      nil ->
        conn
        |> put_status(401)
        |> render(Nexpo.ErrorView, "401.json")

      student ->
        event =
          Repo.get!(Event, event_id)
          |> Repo.preload([:event_info, :event_tickets])

        if event != nil and event.event_info != nil do
          if event.event_info.tickets - Enum.count(event.event_tickets) > 0 do
            event_ticket = %{
              student_id: student.id,
              event_id: event_id,
              photo: photo,
              ticket_code: Comeonin.Bcrypt.hashpwsalt(user.email <> Integer.to_string(event_id))
            }

            case EventTicket.create_ticket(event_ticket) do
              {:ok, struct} ->
                send_resp(conn, :created, "")

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
            end
          else
            conn
            |> put_status(404)
            |> render(Nexpo.ErrorView, "404.json")
          end
        end
    end
  end

  @apidoc """
  @api {DELETE} /api/event/ticket/:id Delete a ticket
  @apiGroup Events
  @apiDescription Remove a ticket for this student
  @apiParam {Integer} id    Id of the event
  @apiSuccessExample {json} Success

  HTTP 204 OK

  @apiUse BadRequestError
  @apiUse UnauthorizedError
  @apiUse NotFoundError
  @apiUse UnprocessableEntity
  """
  def remove_ticket(conn, %{"id" => event_id}, user, _claims) do
    user_student =
      user
      |> Repo.preload([:student])

    case user_student.student do
      nil ->
        conn
        |> put_status(400)
        |> render(Nexpo.ErrorView, "400.json")

      student ->
        ticket =
          EventTicket
          |> where(event_id: ^event_id)
          |> where(student_id: ^student.id)
          |> Repo.one()

        case ticket do
          nil ->
            conn
            |> put_status(404)
            |> render(Nexpo.ErrorView, "404.json")

          ticket ->
            # ni använde "delete!" vilket har annat return värde, så case failade
            case Repo.delete(ticket) do
              {:ok, struct} ->
                send_resp(conn, :no_content, "")

              {:error, changeset} ->
                conn
                |> put_status(:unprocessable_entity)
                |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
            end
        end
    end
  end
end
