defmodule InstagramLink.QueueProcessor do
  def start_link do
    Task.start_link(__MODULE__, :loop, [])
  end

  def loop do
    stream = InstagramLink.QueueEvents.stream
    for _event <- stream do
      process(InstagramLink.Queue.pop)
    end
  end

  defp process({:ok, item}) do
    InstagramLink.CrosspostSup.process item
  end

  defp process({:error, :empty}), do: :ok
end
