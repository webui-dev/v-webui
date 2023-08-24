module vwebui

import time

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

	// The window closes only if the bound v function was called successfully.
	// Therefore we add a 5 sec timeout and check if the function was called.
	// Otherwise the test can run infinitely.
	timeout_ch := chan bool{cap: 1}
	spawn fn (ch chan bool) {
		time.sleep(5 * time.second)
		connected := <-ch
		assert connected
	}(timeout_ch)

	w.bind('test_v_fn', fn [timeout_ch] (e &Event) Response {
		timeout_ch <- true
		assert e.data.string == 'foo'
		e.window.close()
		return 0
	})
	wait()
}
