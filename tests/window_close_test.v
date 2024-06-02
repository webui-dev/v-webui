import vwebui as ui
import vwebui.tests.utils
import time

fn test_window_close() {
	w := ui.new_window()

	// Wait for the window to show
	ui.set_timeout(30)
	w.show(utils.gen_html(@FN, '')) or { assert false, err.str() }
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
	spawn fn [w] () {
		if !utils.timeout(10, fn [w] () bool {
			return !w.is_shown()
		}) {
			assert false, 'Failed closing window.'
		}
	}()
}

fn test_run_wait() {
	ui.wait() // Call wait once at the end of all tests.
}
