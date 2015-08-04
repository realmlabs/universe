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


    #TODO:
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

  def handle_call({:clone, package}, _from, _state) do
    {:reply, {:ok}, []}
    {user, repo} = getPackageURL(package)
                   |> getGitHubURL
                   |> Universe.GitHub.url_to_api

    Universe.GitHub.clone("GitHub", user, repo)
  end

end
