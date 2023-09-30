module vwebui

import json
import time

struct C.GC_stack_base {}

fn C.GC_allow_register_threads()
fn C.GC_get_stack_base(ptr &C.GC_stack_base) int
fn C.GC_register_my_thread(const_ptr &C.GC_stack_base) int
fn C.GC_unregister_my_thread() int

fn (w Window) await_shown(timeout usize) ! {
	for _ in 0 .. timeout * 100 {
		if w.is_shown() {
			return
		}
		// Slow down check interval to reduce load.
		time.sleep(10 * time.millisecond)
	}
	return error('Failed showing window.')
}

fn (e &Event) c_struct() &C.webui_event_t {
	return &C.webui_event_t{
		window: e.window
		event_type: e.event_type
		element: &char(e.element.str)
		data: &char(e.data.str)
		size: e.size
		event_number: e.event_number
	}
}

// @return returns the response to JavaScript.
// This became an internal function that now helps returning values to JS in bind callbacks.
fn (e &Event) @return[T](response T) {
	c_event := e.c_struct()
	$if response is int {
		C.webui_return_int(c_event, i64(response))
	} $else $if response is i64 {
		C.webui_return_int(c_event, response)
	} $else $if response is string {
		C.webui_return_string(c_event, &char(response.str))
	} $else $if response is bool {
		C.webui_return_bool(c_event, response)
	} $else $if response !is voidptr {
		C.webui_return_string(c_event, json.encode(response).str)
	}
}
