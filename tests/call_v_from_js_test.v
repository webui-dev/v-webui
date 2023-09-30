import vwebui as ui
import vwebui.tests.utils

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

struct Person {
	name string
mut:
	age int
}

fn test_get_js_arg() {
	w := ui.new_window()
	w.bind[voidptr]('v_fn_with_string_arg', fn (e &ui.Event) {
		assert e.get_arg[string]() or { '' } == 'foo'
	})
	w.bind[voidptr]('v_fn_with_int_arg', fn (e &ui.Event) {
		assert e.get_arg[int]() or { 0 } == 123
	})
	w.bind[voidptr]('v_fn_with_bool_arg', fn (e &ui.Event) {
		assert e.get_arg[bool]() or { false } == true
	})
	w.bind[voidptr]('v_fn_with_obj_arg', fn (e &ui.Event) {
		assert e.get_arg[Person]() or { Person{} } == Person{'Bob', 30}
	})
	w.bind[voidptr]('v_fn_with_arr_arg', fn (e &ui.Event) {
		assert e.get_arg[[]int]() or { [0] } == [1, 2, 3]
	})
	w.bind[voidptr]('assert_and_exit', fn (e &ui.Event) {
		e.window.close()
	})

	script := '
	setTimeout(async () => {
		console.log("hello")
		const person = {
			name: "Bob",
			age: 30
		}
		await webui.call("v_fn_with_string_arg", "foo");
		await webui.call("v_fn_with_int_arg", 123);
		await webui.call("v_fn_with_bool_arg", true);
		await webui.call("v_fn_with_obj_arg", JSON.stringify(person));
		await webui.call("v_fn_with_arr_arg", JSON.stringify([1, 2, 3]));
		await webui.call("assert_and_exit")
	}, 500)'

	// Show window, wait for it to be recognized as shown.
	w.show(utils.gen_html(@FN, script),
		await: true
	) or { assert false, err.str() }

	// We call `w.close()` from the last V function that is called from JS.
	// Ensure that it closes, otherwise the test can run infinitely. Timeout after 1min.
	if !utils.timeout(60, fn [w] () bool {
		return !w.is_shown()
	}) {
		assert false, 'Timeout while waiting JS calling V.'
	}
}
