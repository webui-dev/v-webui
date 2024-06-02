import log
import vwebui as ui
import vwebui.tests.utils

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
	log.info('> ${@FN} start')
	defer {
		log.info('> ${@FN} end')
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
		assert e.get_arg[string]() or { '' } == 'foo'
		app.fn_was_called = true
	})

	// Show window, wait for it to be recognized as shown.
	w.show(utils.gen_html(@FN, 'setTimeout(async () => { await webui.call("v_fn", "foo"); }, 500)'),
		await: true
	) or { assert false, err.str() }

	log.info('> w.is_shown: ${w.is_shown()}')
	spawn fn [mut app] () {
		if !utils.timeout(30, fn [mut app] () bool {
			return app.fn_was_called
		}) {
			assert false, 'Timeout while waiting for the V callback to be called'
			exit(1)
		}
	}()
}

fn test_run_wait() {
	ui.wait() // Call wait once at the end of all tests.
}
