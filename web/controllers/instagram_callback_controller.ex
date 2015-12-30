defmodule HelloLink.InstagramCallbackController do
  use HelloLink.Web, :controller

  def verify(conn, %{"hub.mode" => "subscribe", "hub.challenge" => challenge, "hub.verify_token" => verify_token}) do
    # Verify token...
    case verify_token == "aoeuaoeu" do
      true ->
        text conn, challenge
      false ->
        conn
        |> put_status(403)
        |> text ""
    end
  end

  def process(conn, %{"_json" => changed}) do
    Enum.each(changed, &HelloLink.Queue.push/1)
    text conn, ""
  end
end
