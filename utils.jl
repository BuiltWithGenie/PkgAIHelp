using Highlights, JuliaFormatter

function highlight_code(code)
    code = format_text(code)
    buf = IOBuffer()
    highlight(buf, MIME("text/html"), code, Lexers.JuliaLexer, Themes.GitHubTheme)
    return String(take!(buf))
end

function highlight_markdown_code_blocks(markdown::String)
    code_block_regex = r"```[\s\S]*?```"

    replacer(m::SubString{String}) = begin
        firstbreak = findfirst("\n", m)[1]
        code = String(strip(m[4:(end - 3)]))
        @show code
        highlighted_code = highlight_code(code)
        @show highlighted_code
        return highlighted_code
    end

    highlighted_markdown = replace(markdown, code_block_regex => replacer)

    return highlighted_markdown
end
