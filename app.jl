using GenieFramework, AIHelpMe, Pkg, JLD2
using AIHelpMe: build_index, load_index!
include("lib/utils.jl")
include("components.jl")
@genietools
Stipple.Layout.add_script("https://cdn.tailwindcss.com")
Stipple.Layout.add_script("https://md-block.verou.me/md-block.js")
#<script type="module" src="https://md-block.verou.me/md-block.js"></script>
_packages = Pkg.installed() |> keys |> collect
@app begin
    # configuration
    @in openai_key = ""
    @in model = "gpt4"
    @out model_options = ["gpt4", "gpt3"]
    @out packages = _packages
    @in index_in_use = "AIHelpMe"
    @in build_index = false
     # chat
    @out history = [("hello","there")]
    @out chat_list = []
    @in question = ""
    @out answer = "answer text here"
    @out cost = 0.0
    @out tokens = 0
    @out total_cost::Float16 = 0.0
    @out total_tokens = 0
    @in submit = false
    @in reset_chat = false
    @in new_chat = false
    @in chat_index = 0
    @in delete_index = 0
    @onbutton submit begin
        response = aihelp(question, model=model)
        answer = response.content
        cost, tokens = round(response.cost,digits=3), response.tokens[1]
        total_cost, total_tokens = total_cost+cost, total_tokens+tokens
        history = vcat((question, answer), history)
        Base.run(__model__, raw"this.scrollToBottom()")
        @show history
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

@methods begin
"""
scrollToBottom: function() {
    const element = document.getElementById('scrollingDiv');
    element.scrollTop = element.scrollHeight;
}
"""
end


ui() = [
        textfield("question",:question),
        cell(class="flex",[
        btn("Submit", @click(:submit), disable="submit"),    spinner("hourglass", color = "primary", size = "20px", @iif(:submit))]),
        chatBubble(:answer),
        h6("History"),
        Html.div(class="mt-10", @recur("pair in history"), 
                 [
                  chatBubble("pair[0]", title="You asked"),
                  chatBubble("pair[1]", title="Answer")
                 ]),
        script(type="module", src="https://md-block.verou.me/md-block.js")
        ]

        @page("/", "app.jl.html")
        load_component("markdowntext")
