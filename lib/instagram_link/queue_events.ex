defmodule InstagramLink.QueueEvents do
  def start_link do
    GenEvent.start_link(name: __MODULE__)
  end
  def stream, do: GenEvent.stream(__MODULE__)
  def notify(event), do: GenEvent.notify(__MODULE__, event)
end
