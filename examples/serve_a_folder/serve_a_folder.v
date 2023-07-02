import vwebui as webui

const (
	my_window        = 1
	my_second_window = 2
)

fn events(e &webui.Event) webui.Response { // Close all opened windows
	// This function gets called every time
	// there is an event
	if e.event_type == .connected {
		println('Connected.')
	} else if e.event_type == .disconnected {
		println('Disconnected.')
	} else if e.event_type == .mouse_click {
		println('Click.')
	} else if e.event_type == .navigation {
		println('Starting navigation to: ${e.data}')
	}
	return 0
}

fn switch_to_second_page(e &webui.Event) webui.Response {
	// This function gets called every
	// time the user clicks on "SwitchToSecondPage"
	// Switch to `/second.html` in the same opened window.
	e.window.show('second.html')
	return 0
}

fn show_second_window(e &webui.Event) webui.Response {
	webui.get_window(my_second_window)
		.show('second.html')
	return 0
}

fn exit_app(e &webui.Event) webui.Response { // Close all opened windows
	webui.exit()
	return 0
}

// Create new windows

webui.new_window_by_id(my_window)
	.bind('SwitchToSecondPage', switch_to_second_page)
	.bind('OpenNewWindow', show_second_window)
	.bind('Exit', exit_app)
	.bind('', events) // Bind events
	.show('index.html') // Show a new window

webui.new_window_by_id(my_second_window)
	.bind('Exit', exit_app)

webui.wait() // Wait until all windows get closed
