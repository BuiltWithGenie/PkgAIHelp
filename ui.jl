StippleUI.layout(view="hHh Lpr lff",
                 [
                  quasar(:header, style="background:black", toolbar(
                                                                       [
                                                                        btn(; dense=true, flat=true, round=true, icon="menu", @click("left_drawer_open = !left_drawer_open")),
                                                                        toolbartitle("AI Help Me!")
                                                                       ],
                                                                      ),
                        ),
                  drawer(bordered="", fieldname="left_drawer_open", side="left", var":mini"="ministate", var"@mouseover"="ministate = false", var"@mouseout"="ministate = true", var"mini-to-overlay"=true, width="170", breakpoint=200, class="bg-black",
                         list(bordered=true, separator=true,
                              [
                               item(clickable="", vripple="", @click("selected_page = 'chat'"),
                                    [
                                     itemsection(avatar=true, icon("chat")),
                                     itemsection("Chat")
                                    ]),
                               item(clickable="", vripple="", @click("selected_page = 'config'"),
                                    [
                                     itemsection(avatar=true, icon("settings")),
                                     itemsection("Configuration")
                                    ]),
                              ]
                             )),

                  page_container(
                                 [
                                  Html.div(class="", @iif("selected_page == 'chat'"),
                                           [
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
                                          ),

                                  Html.div(class="", @iif("selected_page == 'config'"),
                                           [
                                            h3("Configuration"),
                                            cell([
                                                textfield("OpenAI key",:openai_key),
                                                select(:model, options=:model_options, label="Model")
                                                 ])
                                           ])
                                 ])
                 ]
                 )
