defmodule Forwarder do
  use GenEvent
  use ExUnit.Case
  import Poison.Parser

  def handle_event(event, parent) do
    send parent, event
    {:ok, parent}
  end

  setup do
    {:ok, manager} = GenEvent.start_link
    {:ok, github} = Universe.GitHub.start_link(manager)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, github: github}
  end

  #Test json map keys
  test "Verify json has key" do
    #Test using a known commit to make sure we are capable of getting information.
    {status, response} = Universe.GitHub.fetch(Universe.GitHub.tree_url("realmlabs", "universe", "b43e7a02e4819e3802aed69140be5778379c006f"))
    assert status === :ok

    content = parse!(response.body, keys: :atoms)

    #This exists, so we must just be getting limited
    if (response.status_code !== 200) do
      assert Universe.GitHub.verify(content, :documentation_url)
      assert Universe.GitHub.verify(content, :message)
      assert content.documentation_url === "https://developer.github.com/v3/#rate-limiting"
    else
      assert Universe.GitHub.verify(content, :sha)
    end
  end

  #Make sure we format URLs correctly
  test "Tree URL test" do
    assert Universe.GitHub.tree_url("See", "Spot", "Run") === "https://api.github.com/repos/See/Spot/git/trees/Run"
  end

  #Test using a known commit to make sure we are capable of getting information.
  test "proper fetch test" do
    {status, response} = Universe.GitHub.fetch(Universe.GitHub.tree_url("realmlabs", "universe", "b43e7a02e4819e3802aed69140be5778379c006f"))

    case response.status_code do

      #The sha of this commit should be the sha we passed in
      200 ->
        assert status === :ok
        content = parse!(response.body, keys: :atoms).sha
        assert content === "b43e7a02e4819e3802aed69140be5778379c006f"

      #We know this commit exists, it should only fail if we are being limited
      403 ->
        IO.puts("WARN: Requests have been blocked, results of proper fetch test may be innacurate!")
        content = parse!(response.body, keys: :atoms).documentation_url
        assert content === "https://developer.github.com/v3/#rate-limiting"
    end
  end

  #This should 404
  test "Bad url" do
    {status, response} = Universe.GitHub.fetch(Universe.GitHub.tree_url("", "", ""))

    assert status === :ok

    #This should never :ok, the url is bad
    case response.status_code do
      200 ->
        assert false

      #This should either 403 because it doesn't exist/is invisible, or because we are limited.
      403 ->
        content = parse!(response.body, keys: :atoms)
        assert (content.message === "Not Found" or content.documentation_url === "https://developer.github.com/v3/#rate-limiting")

      #Seems to be reserved for malformed requests
      404 ->
        content = parse!(response.body, keys: :atoms).message
        assert content === "Not Found"
    end
  end
end
