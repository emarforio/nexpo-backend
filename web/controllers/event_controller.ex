defmodule Nexpo.EventController do
  use Nexpo.Web, :controller

  alias Nexpo.Event
  alias Nexpo.EventInfo
  alias Nexpo.EventTicket
  alias Nexpo.Student

  def index(conn, %{}) do
    events = Repo.all(Event)

    render(conn, "index.json", events: events)
  end

  def get_event(conn, %{"id" => event_id}) do
    case Repo.get!(Event, event_id) do
      nil ->
        send_resp(conn, :not_found, "")

      event ->
        event = event

        case Repo.get_by(EventInfo, event_id: event_id) do
          nil ->
            send_resp(conn, :not_found, "")

          eventInfo ->
            render(conn, "show.json", event: Map.merge(eventInfo, event))
        end
    end
  end

  """
  def create(conn, %{"id" => event_id}, user) do
    case Repo.get!(Event, event_id) do
      nil ->
        send_resp(conn, :not_found, "")

      event ->
        event = event

        case Repo.get_by(Student, user_id: user.id) do
          nil ->
            send_resp(conn, :not_found, "")
        
          student ->
            student = student

            Repo.insert!(%EventTicket{
              student_id: user.id, 
              event_id: event_id
            })
        end
        events = Repo.all(Event)
        render(conn, "index.json", events: events)
    end
  
  end
  """

  def remove_ticket(conn, %{"id" => event_id}, user, _claims) do
    #student = Repo.get_by!(Student, %{user_id: user.id})

    ticket =
      EventTicket
      |> where(event_id: ^event_id)
      |> where(student_id: ^user.id)
      |> Repo.one
    
    case ticket do
      nil ->
        conn
        |> put_status(404)
        |> render(Nexpo.ErrorView, "404.json")
      
      ticket ->
        case Repo.delete!(ticket) do
          {:ok, struct} -> 
            send_resp(conn, :no_content, "")
    
          {:error, changeset} ->
            send_resp(conn, :not_found, "")
        end
    end
  end
end