defmodule HelloLink.Queue do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def push(item) do
    GenServer.call(__MODULE__, {:push, item})
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  def init(:ok) do
    {:ok, :queue.new}
  end

  def handle_info(:notify_in, queue) do
    HelloLink.QueueEvents.notify(:queue_in)
    {:noreply, queue}
  end

  def handle_call({:push, item}, _from, queue) do
    Kernel.send self, :notify_in
    {:reply, :ok, :queue.in(item, queue)}
  end

  def handle_call(:pop, _from, queue) do
    case :queue.out(queue) do
      {{:value, item}, queue} ->
        {:reply, {:ok, item}, queue}
      {:empty, queue} ->
        {:reply, {:error, :empty}, queue}
    end
  end
end
