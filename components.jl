using GenieFramework
include("utils.jl")

function markdown(text::Union{Symbol, String})
    "<md-block :key='$(string(randn(1)))'>{{$(string(text))}}</md-block>"
end

function chatBubble(text::Union{Symbol, String}; title="Answer")
    @show highlight_markdown_code_blocks(markdown(text))
    card(class="p-4 mt-2", 
         [
          p(class="font-bold", title), 
          highlight_markdown_code_blocks(markdown(text))
                           ])
    
end

