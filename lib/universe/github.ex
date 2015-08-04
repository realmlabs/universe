defmodule Universe.GitHub do
	use GenServer
	import Poison.Parser

	@user_agent [{"User-Agent", "Elixir"}]

	def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

	@doc ~S"""
	Get a tuple representing the user and repo from a url

	## Examples

		iex> Universe.GitHub.url_to_api("https://github.com/realmlabs/universe")
		%{user: "realmlabs", repo: "universe"}

	"""
	def url_to_api(github_url) do
		a = String.split(github_url, "/")
		a = List.delete_at(a, 0)
				|> List.delete_at(0)
				|> List.delete_at(0)
		%{user: List.first(a), repo: List.last(a)}
	end

	#Clientside call to clone repos
	def clone(remote, user, repo, sha \\ "") do
		GenServer.call __MODULE__, {:clone, {remote, user, repo, sha}}
	end

	#Helper function to determine if this map has the key we need
	def verify(jsonMap, keyToTest) do
		keyToTest in Map.keys(jsonMap)
	end


	#Returns the last commit sha
	def getLastCommitSha(user, repo, branch \\ "master", opts \\ []) do
		{:ok, response} = fetch("https://api.github.com/repos/#{user}/#{repo}/git/refs/heads/#{branch}")

		content = parse!(response.body, keys: :atoms)

		if verify(content, :object) do
			content.object.sha
		else
			:bad_verify
		end
	end

	@doc ~S"""
	Returns the tree url to the specified repo and sha

	## Examples

		iex> Universe.GitHub.tree_url("See", "Spot", "Run")
		"https://api.github.com/repos/See/Spot/git/trees/Run"

	"""
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
				#Get the json of the blob
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
		#Get the most recent commit if no commit was specified
		if sha === "" do
			sha = getLastCommitSha(user, repo, "master", %{access_token: "your_token_here", recursive: 1})
		end

		#Get the base tree specified by the user
		{:ok, response} = fetch(tree_url(user, repo, sha), %{access_token: "your_token_here", recursive: 1})

		#Parse the json returned by github
		content = parse!(response.body, keys: :atoms)

		#Verify we have a working tree
		if verify(content, :tree) do

			#Don't litter, place the repo in its own folder
			File.mkdir(repo)

			#Recursively iterate over the json and write the repo to disk
			writeRepoToDisk(content.tree, repo)

			#Return :ok
			{:reply, {:ok, response}, []}
		else

			#Return an error
			{:reply, {:bad_verify}, []}
		end

	end
end
