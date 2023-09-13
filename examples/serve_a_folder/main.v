import vwebui as ui

const (
	w  = ui.Window(1)
	w2 = ui.Window(2)
)

// This function gets called every time there is an event
fn events(e &ui.Event) {
	if e.event_type == .connected {
		println('Connected.')
	} else if e.event_type == .disconnected {
		println('Disconnected.')
	} else if e.event_type == .mouse_click {
		println('Click.')
	} else if e.event_type == .navigation {
		println('Starting navigation to: ${e.string()}')
	}
}

// Switch to `/second.html` in the same opened window.
fn switch_to_second_page(e &ui.Event) {
	e.window.show('second.html') or { eprintln(err) }
}

fn show_second_window(e &ui.Event) {
	w2.show('second.html') or { eprintln(err) }
}

fn exit_app(e &ui.Event) {
	ui.exit()
}

fn main() {
	w.new_window()

	w.bind[voidptr]('SwitchToSecondPage', switch_to_second_page)
	w.bind[voidptr]('OpenNewWindow', show_second_window)
	w.bind[voidptr]('Exit', exit_app)
	w.bind[voidptr]('', events) // Bind events
	w.show('index.html')! // Show a new window

	w2.new_window()
	w2.bind[voidptr]('Exit', exit_app)

	ui.set_root_folder(@VMODROOT)
	ui.wait() // Wait until all windows get closed
}
