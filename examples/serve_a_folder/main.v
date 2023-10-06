import vwebui as ui
import os

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
		target := e.get_arg[string]() or {
			eprintln(err)
			return
		}
		println('Starting navigation to: ${target}')
		w.navigate(target)
	}
}

// Switch to `/second.html` in the same opened window.
fn switch_to_second_page(e &ui.Event) {
	e.window.show('second.html') or { eprintln(err) }
}

fn show_second_window(e &ui.Event) {
	w2.show('second.html', await: true) or { eprintln(err) }
	// Remove the `Go Back` button when showing the second page in another window.
	w2.run("document.getElementById('go-back').remove();")
}

fn exit_app(e &ui.Event) {
	ui.exit()
}

fn main() {
	// Set the root folder for the UI.
	ui.set_root_folder(os.join_path(@VMODROOT, 'ui'))

	// Prepare the main window.
	w.new_window()

	// Bind HTML elements to functions
	w.bind[voidptr]('switch-to-second-page', switch_to_second_page)
	w.bind[voidptr]('open-new-window', show_second_window)
	w.bind[voidptr]('exit', exit_app)
	// Bind all events.
	w.bind[voidptr]('', events)

	// Show the main window.
	w.show('index.html')!

	// Prepare the second window.
	w2.new_window()
	w2.bind[voidptr]('exit', exit_app)

	// Wait until all windows get closed.
	ui.wait()
}
