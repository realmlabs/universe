defmodule Universe.Registry do
	#require HTTPoison
	use GenServer

	@user_agent [{"User-Agent", "Elixir"}]

	def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

	def clone(server, {remote, userandrepo, sha}) do
		GenServer.call(server, {:clone, {remote, userandrepo, sha}})
	end

	def recursive_tree_url(userandrepo, sha) do
		"https://api.github.com/repos/#{userandrepo}/git/trees/#{sha}?recursive=1"
	end

	def fetch(userandrepo, sha) do
		recursive_tree_url(userandrepo, sha)
		|> HTTPoison.get
	end

	def handle_call({:clone, {remote, userandrepo, sha}}, _from, _state) do
		{:reply, fetch(userandrepo, sha), []}
	end
end