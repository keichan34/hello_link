defmodule HelloLink.CrosspostWorker do
  require Logger

  alias HelloLink.Repo
  alias HelloLink.User
  alias HelloLink.InstagramApi
  alias HelloLink.AdnApi

  def start_link(item) do
    Task.start_link(__MODULE__, :init, [item])
  end

  def init(item) do
    IO.inspect item

    item
    |> fetch_from_instagram
    |> post_to_adn

    Process.exit(self, :normal)
  end

  defp fetch_from_instagram(%{"object" => "user", "object_id" => user_id, "data" => %{"media_id" => media_id}} = note) do
    user = Repo.get_by User, instagram_uid: user_id
    Logger.debug "user=#{inspect user} notification=#{inspect note}"
    do_instagram(user, media_id)
  end

  defp do_instagram(nil, _), do: :ignore
  defp do_instagram(user, media_id) when is_binary(media_id) do
    case InstagramApi.get("/v1/media/#{media_id}?access_token=#{user.instagram_token}") do
      {:ok, %HTTPoison.Response{body: response}} ->
        {:ok, user, response["data"]}
    end
  end

  defp post_to_adn(:ignore), do: :ignore
  defp post_to_adn({:ok, %User{id: id, adn_token: nil}, _}) do
    Logger.info "Received Instagram notification for User<#{id}>, but no ADN token was found."
    :ignore
  end
  defp post_to_adn({:ok, _user, %{"type" => "video"}}), do: :ignore
  defp post_to_adn({:ok, user, %{"type" => "image"} = photo}) do
    caption_text = if photo["caption"] do
      photo["caption"]["text"]
    end || ""
    oembed = %{
      "title" => caption_text,
      "version" => "1.0",
      "url" => photo["images"]["standard_resolution"]["url"],
      "height" => photo["images"]["standard_resolution"]["height"],
      "width" => photo["images"]["standard_resolution"]["width"],
      "thumbnail_large_url" => photo["images"]["standard_resolution"]["url"],
      "thumbnail_large_height" => photo["images"]["standard_resolution"]["height"],
      "thumbnail_large_width" => photo["images"]["standard_resolution"]["width"],
      "thumbnail_url" => photo["images"]["thumbnail"]["url"],
      "thumbnail_height" => photo["images"]["thumbnail"]["height"],
      "thumbnail_width" => photo["images"]["thumbnail"]["width"],
      "type" => "photo"
    }

    {text, entities} = HelloLink.Utilities.generate_text_entities(
      caption_text, photo["link"])

    body = %{
      "text" => text,
      "annotations" => [
        %{
          "type" => "net.app.core.oembed",
          "value" => oembed
        },
        %{
          "type" => "net.app.core.crosspost",
          "value" => %{
            "canonical_url" => photo["link"]
          }
        }
      ],
      "entities" => entities
    }

    case AdnApi.post("/posts?include_post_annotations=1", body, [{"Authorization", "Bearer " <> user.adn_token}]) do
      {:ok, _} ->
        Logger.info "X-posted #{photo["link"]}"
    end
  end
end
