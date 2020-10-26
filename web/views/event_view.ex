defmodule Nexpo.EventView do
  use Nexpo.Web, :view

  def render("index.json", %{events: events}) do
    %{data: render_many(events, Nexpo.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Nexpo.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    base = [
      :id,
      :name,
      :date,
      :start,
      :end,
      :location,
      :tickets_left
    ]

    Nexpo.Support.View.render_object(event, base)
  end
end
