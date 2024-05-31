#=
This app implements a web UI for the package AIHelpMe.jl. This package lets you index the documentation from loaded Julia packages and ask questions about it using GPT
=#

using GenieFramework, AIHelpMe, Pkg, JLD2
using AIHelpMe: build_index, load_index!
include("lib/utils.jl")
# load the markdown component to render text
include("components.jl")
@genietools
# this contains the list of installed packages
_packages = Pkg.installed() |> keys |> collect
#reactive code
@app begin
    # First, define reactive variables to hold the state of the UI components
    # configuration
    @in openai_key = ""
    @in model = "gpt4"
    @out model_options = ["gpt4", "gpt3"]
    @out packages = _packages
    @in index_in_use = "AIHelpMe"
    @in build_index = false
    # chat
    @out history = []
    @out chat_list = []
    @in question = ""
    @out answer = "answer text here"
    @out cost = 0.0
    @out tokens = 0
    @out total_cost::Float16 = 0.0
    @out total_tokens = 0
    @in submit = false
    # chat list
    @in reset_chat = false
    @in new_chat = false
    @in chat_index = 0
    @in delete_index = 0
    # Second, define reactive handlers to execute code when a reactive variable changes
    @onbutton submit begin
        response = aihelp(question, model=model)
        answer = response.content
        cost, tokens = round(response.cost,digits=3), response.tokens[1]
        total_cost, total_tokens = total_cost+cost, total_tokens+tokens
        history = vcat(history,(question, answer))
        # this runs a javascript function in the browser
        Base.run(__model__,raw"this.scrollToBottom()")
    end
    @onbutton build_index begin
        idx = build_index(eval(Symbol(index_in_use))) 
        load_index!(idx)
        @save "indexes/$index_in_use.jld2" idx
        notify(__model__, "Index built and loaded.")
    end
    @onchange index_in_use begin
        idx_file = "indexes/$index_in_use.jld2"
        if !isfile(idx_file)
            notify(__model__, "Package not indexed.", :warning)
        else
        @load idx_file idx
        load_index!(idx)
        notify(__model__, "Index loaded.")
        end
    end
    @onbutton reset_chat begin
         history = []
    end
    @onbutton new_chat begin
        chat_list = vcat([history],chat_list)
    end
    @onchange chat_index begin
        history = chat_list[chat_index+1]
        @info "Switched to chat index $(chat_index+1)"
    end
    @onchange delete_index begin
        splice!(chat_list,delete_index+1)
        chat_list = chat_list
        @info "Deleted chat index $(delete_index+1)"
    end
end

# inject javascript method to scroll down the chat history
@methods begin
    """
    scrollToBottom: function() {
        const element = document.getElementById('scrollingDiv');
        element.scrollTop = element.scrollHeight;
    }
    """
end

@page("/", "app.jl.html")

# load the vue component for rendering markdown text. Must be placed
# after the call to @page
load_component("markdowntext")
