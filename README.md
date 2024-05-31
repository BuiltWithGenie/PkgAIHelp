# AIHelpUI

This app implements a web UI for the package [AIHelpMe.jl](https://github.com/svilupp/AIHelpMe.jl). This package lets you index the documentation from loaded Julia packages and ask questions about them using GPT

** REQUIRES AN OPENAI API KEY**
The input box in the app is not working yet, the key must be exported before running the app as

```bash
export OPENAI_API_KEY = <key-goes-here>
```

## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> export OPENAI_API_KEY = <key-goes-here>
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`

