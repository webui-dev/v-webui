import malisipi.vwebui as webui

fn events(e &webui.Event_t) { // Close all opened windows
    // This function gets called every time
    // there is an event
    if e.@type == webui.event_connected {
        println("Connected.")
    } else if e.@type == webui.event_disconnected {
        println("Disconnected.")
    } else if e.@type == webui.event_mouse_click {
        println("Click.")
    } else if e.@type == webui.event_navigation {
        //println("Starting navigation to: ${e.data}")
    }
}

fn switch_to_second_page(e &webui.Event_t) {
    // This function gets called every
    // time the user clicks on "SwitchToSecondPage"
    // Switch to `/second.html` in the same opened window.
    e.window.show("second.html")
}

fn show_second_window(e &webui.Event_t) {
    mut my_second_window := webui.new_window()
    my_second_window.bind("Exit", exit_app)
    my_second_window.show("second.html")
}

fn exit_app(e &webui.Event_t) { // Close all opened windows
    webui.exit()
}

// Create new windows
mut my_window := webui.new_window()

// Bind HTML element IDs with a C functions
my_window.bind("SwitchToSecondPage", switch_to_second_page)
my_window.bind("OpenNewWindow", show_second_window)
my_window.bind("Exit", exit_app)

my_window.bind("", events) // Bind events
my_window.show("index.html") // Show a new window

webui.wait() // Wait until all windows get closed
