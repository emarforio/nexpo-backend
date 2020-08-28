defmodule Nexpo.EventView do
  use Nexpo.Web, :view

  def render("index.json", %{events: events}) do
    %{data: render_many(events, Nexpo.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Nexpo.EventView, "event_info.json")}
  end

  def render("event_info.json", %{event: event}) do
    base = [
      :id,
      :name,
      :date,
      :start,
      :end,
      :location,
      :host,
      :description,
      :language
    ]

    Nexpo.Support.View.render_object(event, base)
  end

  def render("event.json", %{event: event}) do
    base = [
      :id,
      :name,
      :date,
      :start,
      :end,
      :location
    ]

    Nexpo.Support.View.render_object(event, base)
  end
end
