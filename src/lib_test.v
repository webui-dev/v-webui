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

struct Person {
	name string
	age  int
}

fn test_decode() {
	mut w := new_window()
	w.bind('decode', fn (e &Event) {
		p := e.decode[Person]() or {
			eprintln('Failed decoding person. ${err}')
			assert false
			return
		}
		assert p.name == 'john'
		assert p.age == 30
		e.window.close()
	})
	w.show('<!DOCTYPE html>
<html style="background: linear-gradient(to left, #36265a, #654da9);">
	<head>
		<script>
			setTimeout(async () => {
				const person = {
					name: "john",
					age: 30
				}
				await webui.call("decode", JSON.stringify(person));
			}, 500);
		</script>
	</head>
</html>')
}

fn test_start() {
	wait()
}
