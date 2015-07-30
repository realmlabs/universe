defmodule Universe.CLI do

def parse_args(argv) do
pares = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
case parse do
{[help: true],_,_} -> :help
end
end
