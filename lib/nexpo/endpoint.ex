defmodule Nexpo.Endpoint do
  use Phoenix.Endpoint, otp_app: :nexpo

  if Mix.env() == :prod do
    use Sentry.Phoenix.Endpoint
  end

  socket("/socket", Nexpo.UserSocket)

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(Plug.Session,
    store: :cookie,
    key: "_nexpo_key",
    signing_salt: "mK2+SwZ8"
  )

  # Enable CORS
  plug(CORSPlug)

  plug(Nexpo.Router)
end
