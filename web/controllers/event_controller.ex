defmodule Nexpo.EventController do
  use Nexpo.Web, :controller

  alias Nexpo.Event
  alias Nexpo.EventInfo

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
end
