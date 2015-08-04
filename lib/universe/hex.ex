defmodule ListUtility do
  def map([], _func) do
    []
  end
  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end
end

defmodule Universe.Hex do
	use GenServer

  def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

  def clone(package) do
    GenServer.call __MODULE__, {:clone, package}
  end


  @doc ~S"""
  Returns the github from a hex.pm package url

  ## Examples

    iex> Universe.Hex.getPackageURL("poison") |> Universe.Hex.getGitHubURL
    "https://github.com/devinus/poison"

  """
  def getGitHubURL(packageURL) do
    {:ok, response} = HTTPoison.get(packageURL)


    #TODO: Github might not be the only link! Account for this
    #Crawl html to get URL
    url = Floki.find(response.body, ".row")
          |> Floki.find(".links")
          |> Floki.find("li")
          |> Floki.find("a")
          |> Floki.attribute("href")
          |> Floki.text
  end

  @doc ~S"""
  Returns the URL of the given package

  ## Examples

    iex> Universe.Hex.getPackageURL "foobar"
    "https://hex.pm/packages/foobar"

  """
  def getPackageURL(package) do
    "https://hex.pm/packages/#{package}"
  end

  #TODO: Implement
  @doc """
  This should find the dependency list and do something along the lines of
  Universe.Hex.clone(dep) for each of them to account for deps of deps.

  ## Examples
    iex> Universe.Hex.get_package_deps_names("https://hex.pm/packages/airbrake")
    ["poison", "httpoison"]
  """
  def get_package_deps_names(packageURL) do
    {:ok, response} = HTTPoison.get(packageURL)

    #Crawl to dependencies
    deps = Floki.find(response.body, ".row")
    |> Floki.find(".list-unstyled")
    |> Floki.find("li")
    |> Floki.find("a")
    |> Floki.attribute("href")

    #Get rid first entry which is itself
    deps = List.delete_at(deps, 0)

    #Map to package names
    deps = ListUtility.map(deps, &(List.last(String.split(&1, "/"))))
  end

  #Recurse over deps list
  def get_deps([]) do
  end
  def get_deps([head | tail]) do
    clone(head)
    get_deps(tail)
  end

  def handle_call({:clone, package}, _from, _state) do
    {user, repo} = getPackageURL(package)
                   |> getGitHubURL
                   |> Universe.GitHub.url_to_api

    #Recursively pulls deps (Can we handle_call while in a handle_call?)
    getPackageURL(package)
    |> get_package_deps_names
    |> get_deps

    Universe.GitHub.clone("GitHub", user, repo)
  end

end
