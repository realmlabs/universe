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

  test "Registry calls", %{registry: registry} do
    {status, response} = Universe.Registry.clone(registry, {"github", "Snowie/DungeonGen", "39c024a5635078f778c1fe9f8f03b00658ab59c2"})
    assert response.status_code == 200
  end
end