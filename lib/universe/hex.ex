defmodule Universe.Hex do
	use GenServer
	

  def start_link(event_manager, opts \\ []) do
		GenServer.start_link(__MODULE__, event_manager, opts)
	end

  def clone(package) do
    GenServer.call __MODULE__, {:clone, package}
  end
  
  @doc ~S"""
  Returns a URL for a specified hex.pm package and version.

  ## Example:
  
  	iex> Universe.Hex.get_hex_url("httpoison","0.7.3")
	"https://s3.amazonaws.com/s3.hex.pm/tarballs/httpoison-0.7.3.tar"

  """
  def get_hex_url(package, ver) do
    "https://s3.amazonaws.com/s3.hex.pm/tarballs/#{package}-#{ver}.tar"
  end

  #placeholder functions-------------------

  @doc ~S"""

  Get a URL with specified parameters.

  """
  def fetch(url, opts \\ %{}) do
    HTTPoison.get(url, [], params: opts)
  end

  @doc ~S"""

  Get a specified package from hex.pm.

  """
  def get_package(package) do
  end


  @doc ~S"""

  Get dependencies of a package recursively.

  """
  #If no parameters, do nothing.
  def get_deps([]) do
  end
  
  #If dependencies are remaining download first in the list. 
  def get_deps([head|tail]) do
    get_deps(tail)
  end


  #----------------------------------------

  def handle_call({:clone, package}, _from, _state) do
    {:reply, {:ok}, []}
  end

end
