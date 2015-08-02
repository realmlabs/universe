defmodule Universe.Registry do
	use GenServer
	import Poison.Parser

	@user_agent [{"User-Agent", "Elixir"}]

	def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

	#Clientside call to clone repos
	def clone({remote, user, repo, sha}) do
		GenServer.call __MODULE__, {:clone, {remote, user, repo, sha}}
	end

	#Return an api url to the tree in question
	def tree_url(user, repo, sha) do
		"https://api.github.com/repos/#{user}/#{repo}/git/trees/#{sha}"
	end

	#Get a url with specified parameters
	def fetch(url, opts \\ %{}) do
		HTTPoison.get(url, [], params: opts)
	end

	#We've finished recursing, do nothing.
	def writeRepoToDisk([], _repo) do
	end

	#Recurse over our list and write the repo to disk
	def writeRepoToDisk([head | tail], directory) do
		#Choose between different git objects
		case head.type do

			#In the case of a blob, git seems to assure that the directory it is
			# in precedes it, simply write it to disk.
			"blob" ->
			{:ok, response} = fetch(head.url, %{access_token: "your_token_here", recursive: 1})

			#Parse and decode the blob
			content = parse!(response.body, keys: :atoms).content
					  |> String.replace("\n", "")
					  |> Base.decode64!

			#Finally, write the blob to the path
			File.write("#{directory}/"<>head.path, content)

			#Directories are much the same way, it's safe to simply create them
			"tree" -> File.mkdir("#{directory}/"<>head.path)

		end

		#Recurse
		writeRepoToDisk(tail, directory)
	end

	#Catch the call to clone
	def handle_call({:clone, {remote, user, repo, sha}}, _from, _state) do
		#Get the base tree specified by the user
		{:ok, response} = fetch(tree_url(user, repo, sha), %{access_token: "your_token_here", recursive: 1})

		#Parse the json returned by github
		content = parse!(response.body, keys: :atoms)

		#Don't litter, place the repo in its own folder
		File.mkdir(repo)

		#Recursively iterate over the json and write the repo to disk
		writeRepoToDisk(content.tree, repo)

		#Return :ok
		{:reply, {:ok, response}, []}

	end
end
