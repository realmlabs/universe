defmodule Forwarder do
  use GenEvent
  use ExUnit.Case

  def handle_event(event, parent) do
    send parent, event
    {:ok, parent}
  end

  setup do
    {:ok, manager} = GenEvent.start_link
    {:ok, registry} = Universe.Registry.start_link(manager)

    GenEvent.add_mon_handler(manager, Forwarder, self())
    {:ok, registry: registry}
  end

  #Make sure we format URLs correctly
  test "Tree URL test" do
    assert Universe.Registry.tree_url("See", "Spot", "Run") === "https://api.github.com/repos/See/Spot/git/trees/Run"
  end

  #Test using a known commit to make sure we are capable of getting information.
  test "Fetch test" do
    {status, response} = Universe.Registry.fetch(Universe.Registry.tree_url("realmlabs", "universe", "b43e7a02e4819e3802aed69140be5778379c006f"))
    assert response.status_code === 200
    assert status === :ok
  end
end
