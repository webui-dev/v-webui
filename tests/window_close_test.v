import vwebui as ui
import vwebui.tests.utils
import time

fn test_window_close() {
	w := ui.new_window()

	// Wait for the window to show
	ui.set_timeout(30)
	w.show('<html style="background: #654da9; color: #eee">
<head><script src="webui.js"></script></head>
<body><samp>${@FN}</samp></body>
</html>') or {
		assert false, err.str()
	}
	for i in 0 .. 30 {
		if w.is_shown() {
			break
		}
		time.sleep(1 * time.second)
	}
	if !w.is_shown() {
		assert false, 'Timeout showing window.'
	}

	w.close()
	// Wait for the window to close
	if !utils.timeout(10, fn [w] () bool {
		return !w.is_shown()
	}) {
		assert false, 'Failed closing window.'
	}
}
