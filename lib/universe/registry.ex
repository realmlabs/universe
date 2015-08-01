defmodule Universe.Registry do
	#require HTTPoison
	use GenServer
	#use Base
	import Poison.Parser
	#use String

	@user_agent [{"User-Agent", "Elixir"}]

	def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

	def clone({remote, user, repo, sha}) do
		GenServer.call __MODULE__, {:clone, {remote, user, repo, sha}}
	end

	def recursive_tree_url(user, repo, sha) do
		"https://api.github.com/repos/#{user}/#{repo}/git/trees/#{sha}?recursive=1"
	end

	def fetch(url) do
		HTTPoison.get(url)
	end
	
	def writeRepoToDisk([], _repo) do
	end

	def writeRepoToDisk([head | tail], repo) do
		case head.type do
			"blob" -> 
			{:ok, response} = fetch(head.url)
			content = parse!(response.body, keys: :atoms).content
					  |> String.replace("\n", "")
					  |> Base.decode64!
			File.write("#{repo}/"<>head.path, content)

			"tree" -> File.mkdir("#{repo}/"<>head.path)
		end

		writeRepoToDisk(tail, repo)
	end

	def handle_call({:clone, {remote, user, repo, sha}}, _from, _state) do
		{:ok, response} = fetch(recursive_tree_url(user, repo, sha))
		content = parse!(response.body, keys: :atoms)
		File.mkdir(repo)
		writeRepoToDisk(content.tree, repo)
		{:reply, {:ok, response}, []}	

	end
end