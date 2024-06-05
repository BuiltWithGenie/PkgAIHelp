# AIHelpUI

This app implements a web UI for the package [AIHelpMe.jl](https://github.com/svilupp/AIHelpMe.jl). This package lets you index the documentation from loaded Julia packages and ask questions about them using GPT



https://github.com/BuiltWithGenie/PkgAIHelp/assets/5058397/e7986c20-3d63-410c-a162-80f33302f5f5

**REQUIRES AN OPENAI API KEY**. Enter your key in the API KEY text field before entering a question.

## Installation

Clone the repository and install the dependencies:

First `cd` into the project directory then run:

```bash
$> julia --project -e 'using Pkg; Pkg.instantiate()'
```

Then run the app

```bash
$> julia --project
```

```julia
julia> using GenieFramework
julia> Genie.loadapp() # load app
julia> up() # start server
```

## Usage

Open your browser and navigate to `http://localhost:8000/`

