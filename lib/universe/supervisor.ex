defmodule Universe.Supervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, :ok)
	end

	@manager_name Universe.EventManager
	@git_server_name Universe.GitHub
	@hex_name Universe.Hex

	def init(:ok) do
		children = [
			worker(GenEvent, [[name: @manager_name]]),
			worker(Universe.GitHub, [@manager_name, [name: @git_server_name]]),
			worker(Universe.Hex,    [@manager_name, [name: @hex_name]])
		]
		supervise(children, strategy: :one_for_one)
	end
end
