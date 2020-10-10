defmodule Nexpo.EventController do
  use Nexpo.Web, :controller
  # user kommer från Guardian
  use Guardian.Phoenix.Controller

  alias Nexpo.Event
  alias Nexpo.EventInfo
  alias Nexpo.EventTicket
  alias Nexpo.Student

  def index(conn, %{}, _user, _claims) do
    events = Repo.all(Event)

    render(conn, "index.json", events: events)
  end

  def get_event(conn, %{"id" => event_id}, _user, _claims) do
    case Repo.get!(Event, event_id) do
      nil ->
        conn
        |> put_status(404)
        |> render(Nexpo.ErrorView, "404.json")

      event ->
        case Repo.get_by(EventInfo, event_id: event_id) do
          nil ->
            conn
            |> put_status(404)
            |> render(Nexpo.ErrorView, "404.json")

          eventInfo ->
            tickets =
              Repo.all(
                from(event_ticket in EventTicket,
                  where: event_ticket.event_id == ^event_id
                )
              )

            updated_event_info = eventInfo |> struct(%{tickets: Map.get(eventInfo, :tickets) - Enum.count(tickets)})

            IO.inspect(updated_event_info)
            render(conn, "show.json", event: Map.merge(updated_event_info, event))
        end
    end
  end

  def get_tickets(conn, %{}, user, _claims) do
    case Repo.get_by(Student, user_id: user.id) do
      nil ->
        conn
        |> put_status(401)
        |> render(Nexpo.ErrorView, "401.json")

      student ->
        tickets =
          Repo.all(
            from(event_ticket in EventTicket,
              where: event_ticket.student_id == ^student.id
            )
          )

        render(conn, "event_tickets.json", tickets: tickets)
      end
  end

  def get_event2(conn, %{"id" => event_id}, _user, _claims) do
    event = Repo.one from event in Event,
      where: event.id == ^event_id,
      left_join: event_info in assoc(event, :event_info),
      left_join: event_tickets in assoc(event, :event_tickets),
      preload: [event_info: event_info, event_tickets: event_tickets]
    
    case event do
      nil ->
        conn
        |> put_status(404)
        |> render(Nexpo.ErrorView, "404.json")
      
      event ->

        updated_event_info = event.event_info |> struct(%{tickets: Map.get(event.event_info, :tickets) - Enum.count(event.event_tickets)})

        render(conn, "show.json", event: Map.merge(updated_event_info, event))
    end
  end

  def create_ticket(conn, %{"event_id" => event_id}, user, _claims) do
    case Repo.get_by(Student, user_id: user.id) do
      nil ->
        conn
        |> put_status(401)
        |> render(Nexpo.ErrorView, "401.json")

      student ->
        case Repo.get!(Event, event_id) do
          nil ->
            conn
            |> put_status(404)
            |> render(Nexpo.ErrorView, "404.json")

          event ->
            case Repo.get_by(EventInfo, event_id: event_id) do
              nil ->
                conn
                |> put_status(404)
                |> render(Nexpo.ErrorView, "404.json")

              eventInfo ->
                tickets =
                  Repo.all(
                    from(event_ticket in EventTicket,
                      where: event_ticket.event_id == ^event_id
                    )
                  )

                  if Map.get(eventInfo, :tickets) - Enum.count(tickets) > 0 do
                    event_ticket = %EventTicket{
                      student_id: student.id,
                      event_id: event.id,
                      ticket_code: Comeonin.Bcrypt.hashpwsalt(user.email <> Integer.to_string(event_id))
                    }

                    case Repo.insert(EventTicket.changeset(event_ticket)) do
                      {:ok, struct} ->
                        send_resp(conn, :created, "")

                      {:error, changeset} ->
                        conn
                        |> put_status(:unprocessable_entity)
                        |> render(Nexpo.ChangesetView, "error.json", changeset: changeset)
                    end
                  else
                    conn
                    |> put_status(401)
                    |> render(Nexpo.ErrorView, "401.json")
                  end
            end
        end
    end
  end

  def remove_ticket(conn, %{"id" => event_id}, user, _claims) do
    # hämta student med user id
    case Repo.get_by(Student, user_id: user.id) do
      nil ->
        conn
        |> put_status(400)
        |> render(Nexpo.ErrorView, "400.json")

      student ->
        ticket =
          EventTicket
          |> where(event_id: ^event_id)
          |> where(student_id: ^student.id)
          |> Repo.one

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
                |> put_status(404)
                |> render(Nexpo.ErrorView, "404.json")
            end
        end
    end
  end
end
