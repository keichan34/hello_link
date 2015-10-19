defmodule InstagramLink.CrosspostSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def process(item) do
    Supervisor.start_child(__MODULE__, [item])
  end

  def init(:ok) do
    children = [
      worker(InstagramLink.CrosspostWorker, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
