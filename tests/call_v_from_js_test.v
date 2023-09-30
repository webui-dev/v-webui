import vwebui as ui
import vwebui.tests.utils
import time

struct App {
mut:
	fn_was_called bool
}

fn test_v_fn_call() {
	w := ui.new_window()
	mut app := &App{}
	w.bind('v_fn', fn [w, mut app] (e &ui.Event) voidptr {
		app.fn_was_called = true
		e.window.close()
		return ui.no_result
	})
	script := '
	setTimeout(async () => {
		await webui.call("v_fn");
	}, 500)'

	// Show window, wait for it to be recognized as shown.
	w.show(utils.gen_html(@FN, script),
		await: true
	) or { assert false, err.str() }

	// Wait for v_fn to be called.
	if !utils.timeout(30, fn [mut app] () bool {
		return app.fn_was_called
	}) {
		assert false, 'Timeout while waiting for JS to call V.'
	}
}
