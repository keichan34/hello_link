defmodule InstagramLink.UtilitiesTest do
  use ExUnit.Case, async: true

  alias InstagramLink.Utilities

  test "truncate_string returns the original string if it is shorter than the max" do
    str = "hello"
    assert Utilities.truncate_string(str, 10) == str
  end

  test "truncate_string returns the original string if it is exactly the max" do
    str = "hello"
    assert Utilities.truncate_string(str, 5) == str
  end

  test "truncate_string returns a truncated string if it is greater than the max" do
    str = "hello"
    assert Utilities.truncate_string(str, 3) == "he…"
  end

  test "generate_text_entities works" do
    {text, entities} = Utilities.generate_text_entities("Hello there, how are you?", "http://www.example.com")

    assert text == "Hello there, how are you? Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 26,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end

  test "generate_text_entities works with emoji 1" do
    {text, entities} = Utilities.generate_text_entities(
      "SEA 🛫😴🛬ATL☕️☕️☕️🛫🛬BWI.",
      "http://www.example.com")

    assert text == "SEA 🛫😴🛬ATL☕️☕️☕️🛫🛬BWI. Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 23,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end

  test "generate_text_entities works with emoji 2" do
    {text, entities} = Utilities.generate_text_entities(
      "⛷ & ♨️",
      "http://www.example.com")

    assert text == "⛷ & ♨️ Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 7,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end

  test "generate_text_entities works with emoji 3" do
    {text, entities} = Utilities.generate_text_entities(
      "Waffles. 🍴☕️",
      "http://www.example.com")

    assert text == "Waffles. 🍴☕️ Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 13,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end

  test "generate_text_entities works with emoji 4" do
    {text, entities} = Utilities.generate_text_entities(
      "2016 calendar from Yamabicco Design 💌🗓 #calendar #japaneseprint #wp #tw",
      "http://www.example.com")

    assert text == "2016 calendar from Yamabicco Design 💌🗓 #calendar #japaneseprint #wp #tw Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 72,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end

  test "generate_text_entities works with a truncated caption" do
    {text, entities} = Utilities.generate_text_entities("Hello there, how are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you?", "http://www.example.com")

    assert text == "Hello there, how are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you? I am doing very well, thank you very much. How are you?… Image"
    assert entities == %{
      "links" => [
        %{
          "pos" => 251,
          "len" => 5,
          "url" => "http://www.example.com"
        }
      ]
    }
  end
end
