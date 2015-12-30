defmodule HelloLink.QueueProcessor do
  def start_link do
    Task.start_link(__MODULE__, :loop, [])
  end

  def loop do
    stream = HelloLink.QueueEvents.stream
    for _event <- stream do
      process(HelloLink.Queue.pop)
    end
  end

  defp process({:ok, item}) do
    HelloLink.CrosspostSup.process item
  end

  defp process({:error, :empty}), do: :ok
end
