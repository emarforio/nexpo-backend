defmodule Nexpo.CoordinatorPositionView do
  use Nexpo.Web, :view

  def render("index.json", %{positions: positions}) do
    %{data: render_many(positions, Nexpo.CoordinatorPositionView, "position.json", as: :position)}
  end

  def render("position.json", %{position: position}) do
    base = [
      :type,
      :position
    ]

    Nexpo.Support.View.render_object(position, base)
  end
end
