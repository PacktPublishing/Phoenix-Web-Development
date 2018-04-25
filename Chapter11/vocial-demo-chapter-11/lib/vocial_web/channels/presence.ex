defmodule VocialWeb.Presence do
  use Phoenix.Presence,
    otp_app: :vocial,
    pubsub_server: Vocial.PubSub
end