/*
V-WebUI 2.4.0-beta
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
	disconnected        = 0
	connected           = 1
	multi_connection    = 2
	unwanted_connection = 3
	mouse_click         = 4
	navigation          = 5
	callback            = 6
}

pub enum Browser {
	any      = 0
	chrome   = 1
	firefox  = 2
	edge     = 3
	safari   = 4
	chromium = 5
	opera    = 6
	brave    = 7
	vivaldi  = 8
	epic     = 9
	yandex   = 10
}

pub enum Runtime {
	@none  = 0
	deno   = 1
	nodejs = 2
}

pub const no_result = unsafe { nil }

// == Definitions =============================================================

// new_window creates a new webui window object.
pub fn new_window() Window {
	C.GC_allow_register_threads()
	return C.webui_new_window()
}

// new_window creates a new webui window object using a specified window number.
pub fn (w Window) new_window() {
	C.GC_allow_register_threads()
	C.webui_new_window_id(w)
}

// get_new_window_id returns a free window ID that can be used with the `new_window` method.
pub fn get_new_window_id() Window {
	return C.webui_get_new_window_id()
}

// bind binds a specific html element click event with a function. Empty element means all events.
pub fn (w Window) bind[T](element string, func fn (&Event) T) Function {
	return C.webui_bind(w, &char(element.str), fn [func] [T](e &Event) {
		sb := C.GC_stack_base{}
		C.GC_get_stack_base(&sb)
		C.GC_register_my_thread(&sb)
		resp := func(e)
		e.@return(resp)
		C.GC_unregister_my_thread()
	})
}

// show opens a window using embedded HTML, or a file.
// If the window is already open, it will be refreshed.
pub fn (w Window) show(content string) ! {
	if !C.webui_show(w, &char(content.str)) {
		return error('Failed showing window.')
	}
}

// show_browser opens a window using embedded HTML, or a file in a specified browser.
// If the window is already open, it will be refreshed.
pub fn (w Window) show_browser(content string, browser Browser) ! {
	if !C.webui_show_browser(w, &char(content.str), browser) {
		return error('Failed showing window in `${browser}`.')
	}
}

// set_kiosk determines whether Kiosk mode (full screen) is enabled for the window.
pub fn (w Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(w, kiosk)
}

// set_root_folder sets the web-server root folder path for the window.
pub fn (w Window) set_root_folder(path string) {
	C.webui_set_root_folder(w, &char(path.str))
}

// set_root_folder sets the web-server root folder path for all windows.
pub fn set_root_folder(path string) {
	C.webui_set_default_root_folder(&char(path.str))
}

// wait waits until all opened windows get closed.
pub fn wait() {
	C.webui_wait()
}

// close closes the window. The window object will still exist.
pub fn (w Window) close() {
	C.webui_close(w)
}

// destroy closes the window and free all memory resources.
pub fn (w Window) destroy() {
	C.webui_destroy(w)
}

// exit close all open windows. `wait()` will break.
pub fn exit() {
	C.webui_exit()
}

// == Other ===================================================================

// is_show checks if the window is still running.
pub fn (w Window) is_shown() bool {
	return C.webui_is_shown(w)
}

// set_timeout sets the maximum time in seconds to wait for the browser to start.
pub fn set_timeout(timeout usize) {
	C.webui_set_timeout(timeout)
}

// set_icon sets the default embedded HTML favicon.
pub fn (w Window) set_icon(icon string, icon_type string) {
	C.webui_set_icon(w, &char(icon.str), &char(icon_type.str))
}

// set_multi_access determines whether the window URL can be reused in normal web browsers.
pub fn (w Window) set_multi_access(status bool) {
	C.webui_set_multi_access(w, status)
}

// decode decodes Base64 encoded text received from the the UI.
pub fn (e Event) decode[T]() !T {
	return json.decode(T, e.string()) or { return error('Failed decoding arguments. `${err}`') }
}

// set_hide determines whether the window is run in hidden mode.
pub fn (w Window) set_hide(status bool) {
	C.webui_set_hide(w, status)
}

// set_size sets the window size.
pub fn (w Window) set_size(width usize, height usize) {
	C.webui_set_size(w, width, height)
}

// set_position sets the window position.
pub fn (w Window) set_position(x usize, y usize) {
	C.webui_set_position(w, x, y)
}

// == Javascript ==============================================================

// run executes JavaScript without waiting for the response.
pub fn (w Window) run(script string) {
	C.webui_run(w, &char(script.str))
}

// script executes JavaScript and returns the response (Make sure the response buffer can hold the response).
// The default max_response_size is 8KiB.
pub fn (w Window) script(javascript string, opts ScriptOptions) !string {
	mut buffer := []u8{len: int(opts.max_response_size)}.str().str
	if !C.webui_script(w, &char(javascript.str), opts.timeout, &char(buffer), opts.max_response_size) {
		return error('Failed running script. `${javascript}`')
	}
	return unsafe { buffer.vstring() }
}

// set_runtime sets the runtime for .js and .ts files to Deno or Nodejs.
pub fn (w Window) set_runtime(runtime Runtime) {
	C.webui_set_runtime(w, runtime)
}

// int parses the JavaScript argument as integer.
pub fn (e &Event) int() int {
	return int(C.webui_get_int(e))
}

// i64 parses the JavaScript argument as integer.
pub fn (e &Event) i64() i64 {
	return C.webui_get_int(e)
}

// string parses the JavaScript argument as integer.
pub fn (e &Event) string() string {
	// Ensure GCC and Clang compiles with `-cstrict`
	return unsafe { (&char(C.webui_get_string(e))).vstring() }
}

// bool parses the JavaScript argument as integer.
pub fn (e &Event) bool() bool {
	return C.webui_get_bool(e)
}

// @return returns the response to JavaScript.
// This became an internal function that now helps returning values to JS in bind callbacks.
fn (e &Event) @return[T](response T) {
	$if response is int {
		C.webui_return_int(e, i64(response))
	} $else $if response is i64 {
		C.webui_return_int(e, response)
	} $else $if response is string {
		C.webui_return_string(e, &char(response.str))
	} $else $if response is bool {
		C.webui_return_bool(e, response)
	} $else $if response !is voidptr {
		C.webui_return_string(e, json.encode(response).str)
	}
}
