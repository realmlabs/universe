defmodule Universe.Supervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, :ok)
	end

	@manager_name Universe.EventManager
	@registry_name Universe.Registry

	def init(:ok) do
		children = [
			worker(GenEvent, [[name: @manager_name]]),
			worker(Universe.Registry, [@manager_name, [name: @registry_name]])
		]
		supervise(children, strategy: :one_for_one)
	end
end