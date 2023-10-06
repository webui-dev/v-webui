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

// V function bound to JS callback in next tests
fn assert_get_args_at_idx(e &ui.Event) {
	assert e.get_arg[string](idx: 0) or { '' } == 'foo'
	assert e.get_arg[int](idx: 1) or { 0 } == 123
	assert e.get_arg[bool](idx: 2) or { false } == true
	assert e.get_arg[Person](idx: 3) or { Person{} } == Person{'Bob', 30}
	assert e.get_arg[[]int](idx: 4) or { [0] } == [1, 2, 3]
	e.window.close()
}

fn test_get_js_arg_at_idx() {
	w := ui.new_window()
	// V function, called from JS, receiving the above return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_get_args_at_idx', assert_get_args_at_idx)

	script := '
	setTimeout(async () => {
		const str = "foo"
			int = 123,
			bool = true,
			struct = { name: "Bob", age: 30 },
			array = [1, 2, 3];
		await webui.call("assert_get_args_at_idx", str, int, bool, JSON.stringify(struct), JSON.stringify(array));
	}, 500)'

	// Show window, wait for it to be recognized as shown.
	w.show(utils.gen_html(@FN, script),
		await: true
	) or { assert false, err.str() }

	if !utils.timeout(60, fn [w] () bool {
		return !w.is_shown()
	}) {
		assert false, 'Timeout while waiting JS calling V.'
	}
}

fn test_return_value_to_js() {
	w := ui.new_window()
	// Eventually possible with lambda expressions like below. Re-check as V development progresses.
	// w.bind('return_string', |_| 'bar')
	w.bind('v_return_string', fn (e &ui.Event) string {
		return 'foo'
	})
	w.bind('v_return_int', fn (e &ui.Event) int {
		return 123
	})
	w.bind('v_return_bool', fn (e &ui.Event) bool {
		return true
	})
	w.bind('v_return_struct', fn (e &ui.Event) Person {
		return Person{'Bob', 30}
	})
	w.bind('v_return_array', fn (e &ui.Event) []int {
		return [1, 2, 3]
	})
	// V function, called from JS, receiving the above return value as argument and asserts it's correctness.
	w.bind[voidptr]('assert_js_res_from_v', assert_get_args_at_idx)

	script := '
	setTimeout(async () => {
		const str = await webui.call("v_return_string"),
			int = await webui.call("v_return_int"),
			bool = await webui.call("v_return_bool"),
			struct = await webui.call("v_return_struct"),
			array = await webui.call("v_return_array");
			console.log(struct)
		await webui.call("assert_js_res_from_v", str, int, bool, struct, array);
	}, 500)'
	w.show(utils.gen_html(@FN, script),
		await: true
	) or { assert false, err.str() }

	if !utils.timeout(60, fn [w] () bool {
		return !w.is_shown()
	}) {
		assert false, 'Timeout while waiting JS calling V.'
	}
}
