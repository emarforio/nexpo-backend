defmodule Nexpo.FormController do
  use Nexpo.Web, :controller
  # I denna version av phoenix lägger denna raden till User och "claims" till varje request
  use Guardian.Phoenix.Controller
  import Ecto.Query
  alias Nexpo.Form

  def index(conn, %{}, user, _claims) do
    events = Repo.all(Form)

    send_resp(conn, :no_content, "")
    #render(conn, "index.json", forms: forms)
  end

  def get_form(conn, %{"id" => form_id}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  def delete_form(conn, %{"id" => form_id}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  def create_form(conn, %{"data" => data_params}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  def update_form(conn, %{"id" => form_id, "data" => data_params}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  #form responses
  def get_response(conn, %{"id" => form_id}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  def delete_response(conn, %{"id" => response_id}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

  def create_response(conn, %{"id" => form_id, "data" => data_params}, user, _claims) do
    send_resp(conn, :no_content, "")
  end

end