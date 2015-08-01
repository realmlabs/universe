defmodule Universe.Registry do
	use GenServer

	## Client API

	def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

	def clone(server, {remote, userandrepo, sha}) do
		GenServer.call(server, {:clone, {remote, userandrepo, sha}})
	end

	#def init(events) do
	#	{:ok, %{events: events}}
	#end

	def handle_call({:clone, {remote, userandrepo, sha}}, _from, _state) do
		{:reply, "We should pull #{userandrepo}:#{sha} from #{remote}", []}
	end
end