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

  def index(conn, %{}, _user, _claims) do
    events = Repo.all(Event)

    render(conn, "index.json", events: events)
  end

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

  def get_all_tickets(conn, %{}, _user, _claims) do
    tickets = Repo.all(EventTicket)

    render(conn, Nexpo.EventTicketView, "index.json", event_tickets: tickets)
  end

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
