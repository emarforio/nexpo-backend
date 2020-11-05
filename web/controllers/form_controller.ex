defmodule Nexpo.FormController do
  use Nexpo.Web, :controller
  # I denna version av phoenix lägger denna raden till User och "claims" till varje request
  use Guardian.Phoenix.Controller
  import Ecto.Query
  alias Nexpo.Form

  def index(conn, %{}, user, _claims) do
    events = Repo.all(Form)

    render(conn, "index.json", forms: forms)
  end

  def get_form(conn, %{"id" => form_id}, user, _claims) do
    asd
  end

  def delete(conn, %{"id" => form_id}, user, _claims) do
    asd
  end

  def create(conn, %{}, _user, _claims) do
    asd
  end

end