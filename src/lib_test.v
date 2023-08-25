module vwebui

import time

fn test_window_close() {
	w := new_window()
	w.show('<html>Hello</html>')
	time.sleep(5 * time.second)
	w.close()
	// Assert from a thread, as a timeout on the main thread after calling `close()` can also prevent closing the window.
	spawn fn (w Window) {
		time.sleep(5 * time.second)
		if w.is_shown() {
			eprintln('Failed closing window.')
			assert false
		}
	}(w)
}

fn test_v_fn_call() {
	doc := '<!DOCTYPE html>
<html lang="en">
	<head>
		<style>
			body {
				background-color: #1c2128;
				color: AliceBlue;
			}
		</style>
	</head>
	<body>
		<h1>WebUI Test</h1>
	</body>
	<script>
		setTimeout(async () => {
			const res = await webui.call("test_v_fn", "foo");
			console.log(res)
		}, 1000)
	</script>
</html>'

	mut w := new_window()
	w.show(doc)

	// The window closes only if the bound V function was called successfully.
	// Therefore we add a 5 sec timeout and check if the function was called.
	// Otherwise the test can run infinitely.
	timeout_ch := chan bool{cap: 1}
	spawn fn (ch chan bool) {
		time.sleep(5 * time.second)
		connected := <-ch
		assert connected
	}(timeout_ch)

	w.bind('test_v_fn', fn [timeout_ch] (e &Event) {
		timeout_ch <- true
		assert e.string() == 'foo'
		e.window.close()
	})
}

fn test_start() {
	wait()
}
