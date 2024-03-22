module App
using GenieFramework, AIHelpMe
include("components.jl")
@genietools
Stipple.Layout.add_script("https://cdn.tailwindcss.com")

@app begin
    @out history = []
    @in question = "Enter a question"
    @out answer = "```a=3+3```\n"
    @in submit = false
    @onbutton submit begin
        @show "submitting question"
        @show submit, question
        answer = aihelp(question, model_chat="gpt4").content
        @show answer
        history = vcat(history, (question, answer))
        @show history
    end
    @onchange question begin
        @show question
    end
end

ui() = [
        textfield("question",:question),
        btn("Submit", @click(:submit)),
        chatBubble(:answer),
        h6("History"),
        Html.div(class="mt-10", @recur("pair in history"), 
                 [
                  chatBubble("pair[0]", title="You asked"),
                  chatBubble("pair[1]", title="Answer")
                 ]),
        script(type="module", src="https://md-block.verou.me/md-block.js")
        ]

        @page("/", ui)
        up()
    end
