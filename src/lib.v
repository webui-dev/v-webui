/*
V-WebUI 2.3.0
https://github.com/webui-dev/v-webui
Copyright (c) 2023 Mehmet Ali.
Licensed under MIT License.
All rights reserved.
*/

module vwebui

import json

pub type Window = usize

pub type Function = usize

pub type Event = C.webui_event_t

[params]
pub struct ScriptOptions {
	max_response_size usize = 8192
	timeout           usize
}

pub enum EventType {
	disconnected = 0
	connected = 1
	multi_connection = 2
	unwanted_connection = 3
	mouse_click = 4
	navigation = 5
	callback = 6
}

pub enum Browser {
	any = 0
	chrome = 1
	firefox = 2
	edge = 3
	safari = 4
	chromium = 5
	opera = 6
	brave = 7
	vivaldi = 8
	epic = 9
	yandex = 10
}

pub enum Runtime {
	@none = 0
	deno = 1
	nodejs = 2
}

// == Definitions =============================================================

// Create a new webui window object.
pub fn new_window() Window {
	return C.webui_new_window()
}

// Create a new webui window object.
pub fn (w Window) new_window() {
	C.webui_new_window_id(w)
}

// Get a free window ID that can be used with the `new_window` method.
pub fn get_new_window_id() Window {
	return C.webui_get_new_window_id()
}

// Bind a specific html element click event with a function. Empty element means all events.
pub fn (w Window) bind(element string, func fn (&Event)) Function {
	return C.webui_bind(w, &char(element.str), func)
}

// Show a window using embedded HTML, or a file. If the window is already open, it will be refreshed.
pub fn (w Window) show(content string) ! {
	if !C.webui_show(w, &char(content.str)) {
		return error('Failed showing window.')
	}
}

// Show a window using embedded HTML, or a file in a specified browser. If the window is already open, it will be refreshed.
pub fn (w Window) show_browser(content string, browser Browser) ! {
	if !C.webui_show_browser(w, &char(content.str), browser) {
		return error('Failed showing window in `${browser}`.')
	}
}

// Set the window in Kiosk mode (full screen).
pub fn (w Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(w, kiosk)
}

// Set the web-server root folder path for a specific window.
pub fn (w Window) set_root_folder(path string) {
	C.webui_set_root_folder(w, &char(path.str))
}

// Set the web-server root folder path for all windows.
pub fn set_root_folder(path string) {
	C.webui_set_default_root_folder(&char(path.str))
}

// Wait until all opened windows get closed.
pub fn wait() {
	C.webui_wait()
}

// Close the window. The window object will still exist.
pub fn (w Window) close() {
	C.webui_close(w)
}

// Close the window and free all memory resources.
pub fn (w Window) destroy() {
	C.webui_destroy(w)
}

// Close all open windows. `wait()` will break.
pub fn exit() {
	C.webui_exit()
}

// == Other ===================================================================

// Check if the window is still running.
pub fn (w Window) is_shown() bool {
	return C.webui_is_shown(w)
}

// Set the maximum time in seconds to wait for the browser to start.
pub fn set_timeout(timeout usize) {
	C.webui_set_timeout(timeout)
}

// Set the default embedded HTML favicon.
pub fn (w Window) set_icon(icon string, icon_type string) {
	C.webui_set_icon(w, &char(icon.str), &char(icon_type.str))
}

// Allow the window URL to be re-used in normal web browsers.
pub fn (w Window) set_multi_access(status bool) {
	C.webui_set_multi_access(w, status)
}

// == Javascript ==============================================================

// Run JavaScript without waiting for the response.
pub fn (w Window) run(script string) {
	C.webui_run(w, &char(script.str))
}

// Run JavaScript and get the response back (Make sure your local buffer can hold the response).
pub fn (w Window) script(javascript string, opts ScriptOptions) !string {
	mut buffer := []u8{len: int(opts.max_response_size)}.str().str
	if !C.webui_script(w, &char(javascript.str), opts.timeout, &char(buffer), opts.max_response_size) {
		return error('Failed running script. `${javascript}`')
	}
	return unsafe { buffer.vstring() }
}

// Chose between Deno and Nodejs as runtime for .js and .ts files.
pub fn (w Window) set_runtime(runtime Runtime) {
	C.webui_set_runtime(w, runtime)
}

// Parse argument as integer.
pub fn (e &Event) int() int {
	return int(C.webui_get_int(e))
}

// Parse argument as integer.
pub fn (e &Event) i64() i64 {
	return C.webui_get_int(e)
}

// Parse argument as string.
pub fn (e &Event) string() string {
	// Ensure GCC and Clang compiles with `-cstrict`
	return unsafe { (&char(C.webui_get_string(e))).vstring() }
}

// Parse argument as boolean.
pub fn (e &Event) bool() bool {
	return C.webui_get_bool(e)
}

// Decode arguments into a V data type.
pub fn (e Event) decode[T]() !T {
	return json.decode(T, e.string()) or { return error('Failed decoding arguments. `${err}`') }
}

type Response = bool | i64 | int | string

// Return the response to JavaScript.
pub fn (e &Event) @return(response Response) {
	match response {
		int {
			C.webui_return_int(e, i64(response))
		}
		i64 {
			C.webui_return_int(e, response)
		}
		string {
			C.webui_return_string(e, &char(response.str))
		}
		bool {
			C.webui_return_bool(e, response)
		}
	}
}

// Run the window in hidden mode.
pub fn (w Window) set_hide(status bool) {
	C.webui_set_hide(w, status)
}
