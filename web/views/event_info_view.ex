defmodule Nexpo.EventInfoView do
  use Nexpo.Web, :view

  def render("event_info.json", %{event_info: event_info}) do
    # Define own parameters to keep
    base = [:id, :host, :description, :language, :tickets]

    Nexpo.Support.View.render_object(event_info, base)
  end
end
