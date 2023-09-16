import log
import time
import vwebui as ui

fn wait_condition(max_iterations int, sleep_duration time.Duration, cb fn () bool) bool {
	for i in 0 .. max_iterations {
		if cb() {
			return true
		}
		time.sleep(sleep_duration)
	}
	return false
}

struct App {
mut:
	fn_was_called bool
}

fn allocate_lots_of_memory() {
	log.info('allocate_lots_of_memory start')
	for _ in 0 .. 1000 {
		_ := 'abdef'.repeat(1000)
	}
	log.info('allocate_lots_of_memory end')
}

// WebUI launches its own threads for the web server.
// The garbage collector could be triggered unintentionally and destroy variables in bind callbacks.
// This test ensures a regression of the GC fix.
fn test_thread_gc() {
	log.info('> ${@METHOD} start')
	defer {
		log.info('> ${@METHOD} end')
	}

	allocate_lots_of_memory()

	mut app := &App{}
	w := ui.new_window()
	defer {
		log.info('>> destroying window')
		w.destroy()
	}

	w.bind[voidptr]('v_fn', fn [mut app] (e &ui.Event) {
		log.info('>>> v_fn called')
		defer {
			log.info('>>> v_fn ended')
		}
		allocate_lots_of_memory()
		assert e.string() == 'foo'
		app.fn_was_called = true
	})

	w.show('<html style="background: #654da9; color: #eee">
<head><script src="webui.js"></script></head>
<body>
	<samp>${@FN}</samp>
	<script>setTimeout(async () => { await webui.call("v_fn", "foo"); }, 1000)</script>
</body>
</html>') or {
		assert false, 'Failed at w.show'
	}

	// Wait for the window to show
	ui.set_timeout(30)
	if !wait_condition(300, 100 * time.millisecond, fn [w] () bool {
		return w.is_shown()
	}) {
		assert false, 'Timeout showing window.'
	}
	log.info('> w.is_shown: ${w.is_shown()}')
	if !wait_condition(300, 100 * time.millisecond, fn [mut app] () bool {
		return app.fn_was_called
	}) {
		assert false, 'Timeout while waiting for the v binded callback to be called'
	}
}
