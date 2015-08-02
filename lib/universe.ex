defmodule Universe do
  use Application
  def start(_type, _args) do
  	Universe.Supervisor.start_link
  end
end
