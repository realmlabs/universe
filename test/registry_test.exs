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
    response = Universe.Registry.get(registry, {"github", "ex/ex", "101"})
    assert response == "text"
  end
end