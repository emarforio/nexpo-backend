defmodule Nexpo.CoordinatorPositionController do
  use Nexpo.Web, :controller

  alias Nexpo.CoordinatorPosition

  def index(conn, %{}) do
    positions = Repo.all(CoordinatorPosition)

    render(conn, "index.json", positions: positions)
  end

end
