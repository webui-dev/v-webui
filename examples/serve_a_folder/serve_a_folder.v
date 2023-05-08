// v install https://github.com/malisipi/vwebui
import malisipi.vwebui as webui

fn events(e &webui.Event) webui.Response { // Close all opened windows
    // This function gets called every time
    // there is an event
    if e.event_type == webui.event_connected {
        println("Connected.")
    } else if e.event_type == webui.event_disconnected {
        println("Disconnected.")
    } else if e.event_type == webui.event_mouse_click {
        println("Click.")
    } else if e.event_type == webui.event_navigation {
        //println("Starting navigation to: ${e.data}")
    }
    return 0
}

fn switch_to_second_page(e &webui.Event) webui.Response {
    // This function gets called every
    // time the user clicks on "SwitchToSecondPage"
    // Switch to `/second.html` in the same opened window.
    e.window.show("second.html")
    return 0
}

fn show_second_window(e &webui.Event) webui.Response {
    webui.new_window()
    	.bind("Exit", exit_app)
    	.show("second.html")
    return 0
}

fn exit_app(e &webui.Event) webui.Response { // Close all opened windows
    webui.exit()
    return 0
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
