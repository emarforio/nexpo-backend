defmodule Nexpo.StatisticsController do
  use Nexpo.Web, :controller

  alias Nexpo.Statistics

  @apidoc """
  @api {GET} /api/statistics Get all statistics
  @apiGroup Statistics
  @apiDescription Fetch all available statistics
  @apiSuccessExample {json} Success

  HTTP 200 OK
  {
    "data": {
      "words_per_appl": 1.2857142857142858,
      "nbr_students": 3,
      "nbr_searching_students": 3,
      "company_stats": [
          {
              "scored_applications": 2,
              "nbr_applications": 2,
              "name": "Google",
              "id": 1
          },
          {
              "scored_applications": 2,
              "nbr_applications": 2,
              "name": "Spotify",
              "id": 2
          },
          {
              "scored_applications": 3,
              "nbr_applications": 3,
              "name": "Intel",
              "id": 3
          }
      ],
      "applications_per_day": [
          "2020-11-05T14:37:19.298619",
          "2020-11-05T14:37:19.302892",
          "2020-11-05T14:37:19.314837",
          "2020-11-05T14:37:19.306844",
          "2020-11-05T14:37:19.290003",
          "2020-11-05T14:37:19.293738",
          "2020-11-05T14:37:19.310778"
      ]
    }
  }

  """
  def index(conn, _params) do
    statistics = Statistics.get_all()
    render(conn, "index.json", statistics: statistics)
  end
end
