import vwebui as ui
import os
import time

const (
	w  = ui.Window(1)
	w2 = ui.Window(2)
)

// This function gets called every time there is an event.
fn events(e &ui.Event) {
	if e.event_type == .connected {
		println('Connected.')
	} else if e.event_type == .disconnected {
		println('Disconnected.')
	} else if e.event_type == .mouse_click {
		println('Click.')
	} else if e.event_type == .navigation {
		println('Starting navigation to: ${e.get_arg[string]() or {}}')
	}
}

// Switch to `/second.html` in the same opened window.
fn switch_to_second_page(e &ui.Event) {
	e.window.show('second.html') or { eprintln(err) }
}

fn show_second_window(e &ui.Event) {
	w2.show('second.html') or { eprintln(err) }
	// Remove Go Back button when showing second page in another window.
	// Give the window 10 seconds to show up.
	for _ in 0 .. 1000 {
		if w2.is_shown() {
			break
		}
		// Slow down check interval to reduce load.
		time.sleep(10 * time.millisecond)
	}
	if !w2.is_shown() {
		return
	}
	// Let DOM load.
	time.sleep(50 * time.millisecond)
	// Remove button.
	w2.run("document.getElementById('go-back').remove();")
}

fn exit_app(e &ui.Event) {
	ui.exit()
}

fn main() {
	w.new_window()

	w.bind[voidptr]('switch-to-second-page', switch_to_second_page)
	w.bind[voidptr]('open-new-window', show_second_window)
	w.bind[voidptr]('exit', exit_app)
	w.bind[voidptr]('', events) // Bind all events.
	w.show('index.html')! // Show a new window.

	w2.new_window()
	w2.bind[voidptr]('exit', exit_app)

	ui.set_root_folder(os.join_path(@VMODROOT, 'ui'))
	ui.wait() // Wait until all windows get closed.
}
