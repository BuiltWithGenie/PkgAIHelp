#=
This app implements a web UI for the package AIHelpMe.jl. This package lets you index the documentation from loaded Julia packages and ask questions about it using GPT
=#

using GenieFramework, AIHelpMe, Pkg, JLD2, Dates
using AIHelpMe: build_index, load_index!
using AIHelpMe.PT.Experimental.RAGTools: airag, setpropertynested

include("lib/utils.jl")
# load the markdown component to render text
include("components.jl")
@genietools
# this contains the list of installed packages
_packages = Pkg.installed() |> keys |> collect
_kwargs = AIHelpMe.PT.Experimental.RAGTools.setpropertynested(AIHelpMe.RAG_KWARGS[],[:embedder_kwargs],:api_key,"")
index_names = replace.(readdir("indexes"), ".jld2"=>"")
global indexes = Dict()

const expiration_time = 60*1000
@async begin
    while true 
        try
        for pair in indexes
            if now() - pair[2].last_used  > Millisecond(expiration_time)
                delete!(indexes, pair[1])
                @info "Deleted index of session $(pair[1])"
            end
        end
         catch e
            @error "Error in async task: $e"
        end
        sleep(30)
    end
end

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
    @private sessionid = ""
    @private kwargs = _kwargs
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
    # when the page is loaded (isready), load a default index
    @onchange isready begin
        sessionid = Stipple.sessionid()
        indexes[sessionid] = (index=load("indexes/$index_in_use.jld2")["idx"], last_used=now())
        @info "loaded index for $sessionid"
    end
    # When the submit button is clicked, send the question the GPT API and update the metrics
    @onbutton submit begin
        if !haskey(indexes, sessionid);  indexes[sessionid] = (index=load("indexes/$index_in_use.jld2")["idx"], last_used=now()); end
        response = AIHelpMe.PT.Experimental.RAGTools.airag(AIHelpMe.RAG_CONFIG[], indexes[sessionid].index; question, kwargs...)
        answer = response.content
        cost, tokens = round(response.cost,digits=3), response.tokens[1]
        total_cost, total_tokens = total_cost+cost, total_tokens+tokens
        history = vcat(history,(question, answer))
        # this runs a javascript function in the browser
        Base.run(__model__,raw"this.scrollToBottom()")
    end
    # When the build index button is clicked, index the selected package and store the result
    @onbutton build_index begin
        idx = build_index(eval(Symbol(index_in_use))) 
        indexes[sessionid] = (index=idx, last_used = now())
        @save "indexes/$index_in_use.jld2" idx
        notify(__model__, "Index built and loaded.")
    end
    # When a new package is selected in the dropdown, load the associated index from disk
    @onchange index_in_use begin
        if !isfile("indexes/$index_in_use.jld2")
            notify(__model__, "Package not indexed.", :warning)
        else
        indexes[sessionid] = (index=load("indexes/$index_in_use.jld2")["idx"], last_used=now())
        notify(__model__, "Index loaded.")
        end
    end
    @onchange openai_key begin
        kwargs = setpropertynested(AIHelpMe.RAG_KWARGS[],[:embedder_kwargs],:api_key,openai_key)
    end
    @onbutton reset_chat begin
         history = []
    end
    @onbutton new_chat begin
        chat_list = vcat([history],chat_list)
        history = []
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
