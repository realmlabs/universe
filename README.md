# universe
Allows Nirvana apps to access the universe of libraries, dynamically.


## CHALLENGE

This will be a library and a dependency of Nirvana. It provides acceess to
github using the github API (and eventually maybe bitbucket or other places)
so that Nirvana apps can reference them.  

- Should take a reference along the lines of {"github", "nirvana/sofo",
"13ef6092b75d95995c9ac377a86f0e4a88e6ebe0") or a tag instead of the commit hash. (Github may use the shortened form in their API not sure.)
- When this is a valid repository and commit, it should clone the repo to the
local drive.
- DO THIS WITHOUT GIT INSTALLED ON THE LOCAL MACHINE. (eventualy this will be
putting the repo into the datagbase, not the local directory structure.)
- This may involve walking the tree of the repo, but it will be used for 
repos of a specific structure so the tree walking code can be simple

You will probably need this:
https://github.com/inaka/erlang-github

#### BONUS:  Include API access to the hex.pm repos

#### SUPER BONUS:  Figure out how to load a hex.pm library into the elixir VM at runtime and then call it!
