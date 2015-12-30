defmodule HelloLink.AdnAccountApi do
  use HTTPoison.Base

  def process_url(url) do
    "https://account.app.net" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
  end
end
