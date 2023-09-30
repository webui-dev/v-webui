import vwebui as ui
import vwebui.tests.utils

fn test_js_fn_call() {
	w := ui.new_window()
	w.bind[voidptr]('v_fn', fn (e &ui.Event) {
		// Call a JS function that calls another V function.
		e.window.run('await callV();')
	})
	w.bind[voidptr]('close_window', fn (e &ui.Event) {
		e.window.close()
	})
	script := '
	setTimeout(async () => {
		await webui.call("v_fn", "foo");
	}, 1000)
	async function callV() {
		res = await webui.call("v_fn");
		await webui.call("close_window")
	}'
	// Show window, wait for it to be recognized as shown.
	w.show(utils.gen_html(@FN, script),
		await: true
	) or { assert false, err.str() }

	// We call `w.close()` from the last V function that is called from JS.
	// Ensure that it closes, otherwise the test can run infinitely. Timeout after 1min.
	if !utils.timeout(30, fn [w] () bool {
		return !w.is_shown()
	}) {
		assert false, 'Timeout while waiting for JS to call V.'
	}
}
