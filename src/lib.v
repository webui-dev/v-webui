/*
V-WebUI 2.3.0
https://github.com/webui-dev/v-webui
Copyright (c) 2023 Mehmet Ali.
Licensed under MIT License.
All rights reserved.
*/

module vwebui

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

pub type Window = usize

pub type Function = usize

pub type Event = C.webui_event_t

pub fn (e &Event) string() string {
	// Ensure GCC and Clang compiles with `-cstrict` flag
	return unsafe { (&char(C.webui_get_string(e))).vstring() }
}

pub fn (e &Event) int() int {
	return int(C.webui_get_int(e))
}

pub fn (e &Event) i64() i64 {
	return C.webui_get_int(e)
}

pub fn (e &Event) bool() bool {
	return C.webui_get_bool(e)
}

pub fn (window Window) script(javascript string, timeout usize, size_buffer int) string {
	response := &char(' '.repeat(size_buffer).str)
	C.webui_script(window, &char(javascript.str), timeout, response, size_buffer)
	return unsafe { response.vstring() }
}

type Response = bool | i64 | int | string

pub fn (e &Event) @return(response Response) {
	match response {
		string {
			C.webui_return_string(e, &char(response.str))
		}
		int {
			C.webui_return_int(e, i64(response))
		}
		i64 {
			C.webui_return_int(e, response)
		}
		bool {
			C.webui_return_bool(e, response)
		}
	}
}

// Create a new webui window object.
pub fn new_window() Window {
	return C.webui_new_window()
}

// Wait until all opened windows get closed.
pub fn wait() {
	C.webui_wait()
}

// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.
pub fn (window Window) show(content string) bool {
	return C.webui_show(window, &char(content.str))
}

// Show a window using a embedded HTML, or a file with specific browser. If the window is already opened then it will be refreshed.
pub fn (window Window) show_browser(content string, browser_id Browser) bool {
	return C.webui_show_browser(window, &char(content.str), browser_id)
}

// Check a specific window if it's still running
pub fn (window Window) is_shown() bool {
	return C.webui_is_shown(window)
}

// Allow the window URL to be re-used in normal web browsers
pub fn (window Window) set_multi_access(status bool) {
	C.webui_set_multi_access(window, status)
}

// Run JavaScript quickly with no waiting for the response.
pub fn (window Window) run(script string) {
	C.webui_run(window, &char(script.str))
}

// Chose between Deno and Nodejs runtime for .js and .ts files.
pub fn (window Window) set_runtime(runtime Runtime) {
	C.webui_set_runtime(window, runtime)
}

// Close a specific window only.
pub fn (window Window) close() {
	C.webui_close(window)
}

// Close a specific window and clear all resources.
pub fn (window Window) destroy() {
	C.webui_destroy(window)
}

// Close all opened windows. webui_wait() will break.
pub fn exit() {
	C.webui_exit()
}

pub fn (window Window) set_root_folder(path string) {
	C.webui_set_root_folder(window, &char(path.str))
}

// Set the window in Kiosk mode (Full screen)
pub fn (window Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(window, kiosk)
}

// Bind a specific html element click event with a function. Empty element means all events.
pub fn (window Window) bind(element string, func fn (&Event)) Function {
	return C.webui_bind(window, &char(element.str), func)
}

// Set the maximum time in seconds to wait for browser to start
pub fn set_timeout(timeout usize) {
	C.webui_set_timeout(timeout)
}

pub fn (win_id Window) new_window() {
	C.webui_new_window_id(win_id)
}

pub fn get_new_window_id() Window {
	return C.webui_get_new_window_id()
}
