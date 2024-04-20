module App
using GenieFramework, AIHelpMe
include("components.jl")
@genietools
Stipple.Layout.add_script("https://cdn.tailwindcss.com")
Stipple.Layout.add_script("https://md-block.verou.me/md-block.js")

@app begin
    # layout and page management
    @in left_drawer_open = true
    @in selected_page = "chat"
    @in ministate = true
    # configuration
    @in openai_key = ""
    @in model = "gpt4"
    @out model_options = ["gpt4t", "gpt3t", "gllama370"]
    @in packs = ["julia"]
    @out packs_options = ["julia", "makie", "tidier"]
    # chat
    @out history = []
    @in question = ""
    @out answer = "```a=3+3```\n"
    @in submit = false
    @onchange isready begin
        packs = ["julia"]
    end
    @onchange packs begin
        @show packs
        AIHelpMe.load_index!(Symbol.(packs))
    end
    @onbutton submit begin
        @show "submitting question"
        @show submit, question
        result = aihelp(question, model = model, return_all = true)
        @show result.final_answer
        history = vcat(history, (question, result.final_answer))
        @show history
    end
    @onchange question begin
        @show question
    end
end

function ui()
    [
        textfield("question", :question),
        cell(class = "flex",
            [
                btn("Submit", @click(:submit), disable = "submit"), spinner(
                    "hourglass", color = "primary", size = "20px", @iif(:submit))]),
        chatBubble(:answer),
        h6("History"),
        Html.div(class = "mt-10", @recur("pair in history"),
            [
                chatBubble("pair[0]", title = "You asked"),
                chatBubble("pair[1]", title = "Answer")
            ]),
        script(type = "module", src = "https://md-block.verou.me/md-block.js")
    ]
end

@page("/", "ui.jl")
up()
end
