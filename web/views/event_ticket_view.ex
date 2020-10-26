defmodule Nexpo.EventTicketView do
  use Nexpo.Web, :view

  def render("index.json", %{event_tickets: event_tickets}) do
    %{data: render_many(event_tickets, Nexpo.EventTicketView, "event_ticket.json")}
  end

  def render("show.json", %{event_ticket: event_ticket}) do
    %{data: render_one(event_ticket, Nexpo.EventTicketView, "event_ticket.json")}
  end

  def render("event_ticket.json", %{event_ticket: event_ticket}) do
    # Define own parameters to keep
    base = [:id, :ticket_code, :photo, :event_id]

    Nexpo.Support.View.render_object(event_ticket, base)
  end
end
