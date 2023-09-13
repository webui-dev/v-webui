import vwebui as ui
import time

struct Person {
	name string
mut:
	age int
}

fn test_fn_call() {
	w := ui.new_window()

	// Initial function that is being called from the browser.
	w.bind('v_fn', fn (e &ui.Event) voidptr {
		assert e.string() == 'foo'
		// Call a JS function that calls another V function.
		e.window.run('await callV();')
		return ui.no_result
	})
	// Next V function that is called from the JS function `callV()` that is called above.
	w.bind('v_fn_with_obj_arg', fn (e &ui.Event) Person {
		mut p := e.decode[Person]() or {
			eprintln('Failed decoding person. ${err}')
			assert false
			exit(0)
		}
		println(p)
		assert p.name == 'john'
		assert p.age == 30
		p.age = 31
		return p
	})
	// Next V function that receives the above return value as argument,
	// asserts it's correctness and closes the window.
	// Uses the alternative generic declaration for a function with a void return value,
	// omitting the need to add a return to the function body.
	w.bind[voidptr]('assert_and_exit', fn (e &ui.Event) {
		mut p := e.decode[Person]() or {
			eprintln('Failed decoding person. ${err}')
			assert false
			exit(0)
		}
		assert p.name == 'john'
		assert p.age == 31
		e.window.close()
	})

	w.show('<html style="background: #654da9; color: #eee">
<head>
	<script src="/webui.js"></script>
</head>
<body>
	<samp>${@FN}</samp>
	<script>
		setTimeout(async () => {
			await webui.call("v_fn", "foo");
		}, 1000)
		async function callV() {
			const person = {
				name: "john",
				age: 30
			}
			res = await webui.call("v_fn_with_obj_arg", JSON.stringify(person));
			await webui.call("assert_and_exit", JSON.stringify(res))
		}
	</script>
</body>
</html>') or {
		assert false
	}

	// Wait for the window to show
	ui.set_timeout(30)
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

	// We call `w.close()` from the last V function that is called from JS.
	// Ensure that it closes, otherwise the test can run infinitely. Timeout after 1min.
	for i in 0 .. 60 {
		if !w.is_shown() {
			return
		}
		time.sleep(1 * time.second)
	}
	eprintln('Failed closing window.')
	assert false
}
