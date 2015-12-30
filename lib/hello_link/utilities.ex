defmodule HelloLink.Utilities do
  @link_text "Image"

  def generate_text_entities(caption_text, url) do
    link_text_length = @link_text |> String.length
    max = 256 - (link_text_length + 1)
    text = caption_text |> truncate_string(max)
    pos = (String.codepoints(text) |> length) + 1
    text = text <> " " <> @link_text

    entities = %{
      "links" => [
        %{
          "pos" => pos,
          "len" => link_text_length,
          "url" => url
        }
      ]
    }

    {text, entities}
  end

  def truncate_string(string, max) do
    case String.length(string) do
      len when len > max ->
        {head, _} = String.split_at(string, max - 1)
        head <> "…"
      _ ->
        string
    end
  end
end
