defmodule Universe.Hex do
	use GenServer

  def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

  def clone(package) do
    GenServer.call __MODULE__, {:clone, package}
  end

  def handle_call({:clone, package}, _from, _state) do
    {:reply, {:ok}, []}
  end

end
