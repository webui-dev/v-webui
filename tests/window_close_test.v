import vwebui as ui
import time

fn test_window_close() {
	w := ui.new_window()

	// Wait for the window to show
	ui.set_timeout(30)
	w.show('<html style="background: #654da9; color: #eee">
<head><script src="/webui.js"></script></head>
<body><samp>${@FN}</samp></body>
</html>') or {
		assert false
	}
	for i in 0 .. 30 {
		if w.is_shown() {
			break
		}
		time.sleep(1 * time.second)
	}
	if !w.is_shown() {
		eprintln('Timeout showing window.')
		assert false
	}

	// Wait for the window to close
	w.close()
	time.sleep(3 * time.second)
	if w.is_shown() {
		eprintln('Failed closing window.')
		assert false
	}
}
