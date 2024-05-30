import GenieFramework.Genie.Renderer.Html: normal_element, register_normal_element

function notify_msg(msg::String, type::Symbol = :info)
    eval(:(notify(__model__, msg, type)))
end

function load_component(name)
    component_code() = [script(read("components/$name.js", String))]
    @deps Main_ReactiveModel component_code
    #= Stipple.register_components(Main_ReactiveModel, name, legacy = true) =#
    register_normal_element(replace(name, "-"=>"__"), context = @__MODULE__)
end

