/*
V-WebUI 2.4.0-beta
https://github.com/webui-dev/v-webui
Copyright (c) 2023 Mehmet Ali.
Copyright (c) 2023 WebUI Contributors.
Licensed under MIT License.
All rights reserved.
*/

module vwebui

import json

// A Window number of a WebUI window.
pub type Window = usize

// A unique function ID returned by the bind event.
pub type Function = usize

// An Event which a V function receives that is called by javascript.
pub struct Event {
	size usize // JavaScript data len
pub:
	window       Window    // The window object number
	event_type   EventType // Event type
	element      string    // HTML element ID
	data         string    // JavaScript data
	event_number usize     // Internal WebUI
}

[params]
pub struct ScriptOptions {
	// The maximum buffer size for the script response.
	max_response_size usize = 8 * 1024
	// Timeout in seconds.
	timeout usize
}

[params]
pub struct ShowOptions {
	// Wait for the window to be recognized as shown.
	await bool
	// Timeout in seconds.
	timeout usize = 10
}

pub enum EventType {
	disconnected
	connected
	multi_connection
	unwanted_connection
	mouse_click
	navigation
	callback
}

pub enum Browser {
	no_browser
	any
	chrome
	firefox
	edge
	safari
	chromium
	opera
	brave
	vivaldi
	epic
	yandex
	chromium_based
}

pub enum Runtime {
	@none
	deno
	nodejs
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

// new_window_id returns a free window ID that can be used with the `new_window` method.
pub fn new_window_id() Window {
	return C.webui_get_new_window_id()
}

// bind binds a specific html element click event with a function. Empty element means all events.
pub fn (w Window) bind[T](element string, func fn (&Event) T) Function {
	return C.webui_bind(w, &char(element.str), fn [func] [T](c_event &C.webui_event_t) {
		// Register internal WebUI thread in V GC.
		sb := C.GC_stack_base{}
		C.GC_get_stack_base(&sb)
		C.GC_register_my_thread(&sb)
		// Create V event from C event.
		e := Event{
			window: c_event.window
			event_type: c_event.event_type
			element: unsafe { if c_event.element != nil { c_event.element.vstring() } else { '' } }
			data: unsafe { if c_event.data != nil { c_event.data.vstring() } else { '' } }
			size: c_event.size
			event_number: c_event.event_number
		}
		// Call user callback function and return response.
		e.@return(func(e))
		C.GC_unregister_my_thread()
	})
}

// show opens a window using embedded HTML, or a file.
// If the window is already open, it will be refreshed.
pub fn (w Window) show(content string, opts ShowOptions) ! {
	if !C.webui_show(w, &char(content.str)) {
		return error('Failed showing window.')
	}
	if opts.await {
		return w.await_shown(opts.timeout)
	}
}

// show_browser opens a window using embedded HTML, or a file in a specified browser.
// If the window is already open, it will be refreshed.
pub fn (w Window) show_browser(content string, browser Browser, opts ShowOptions) ! {
	if !C.webui_show_browser(w, &char(content.str), browser) {
		return error('Failed showing window in `${browser}`.')
	}
	if opts.await {
		return w.await_shown(opts.timeout)
	}
}

// set_kiosk determines whether Kiosk mode (full screen) is enabled for the window.
pub fn (w Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(w, kiosk)
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

// set_root_folder sets the web-server root folder path for the window.
pub fn (w Window) set_root_folder(path string) {
	C.webui_set_root_folder(w, &char(path.str))
}

// set_root_folder sets the web-server root folder path for all windows.
pub fn set_root_folder(path string) {
	C.webui_set_default_root_folder(&char(path.str))
}

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

// encode sends text based data to the UI using Base64 encoding.
pub fn encode(data string) string {
	return unsafe { C.webui_encode(&char(data.str)).vstring() }
}

// decode decodes Base64 encoded text received from the the UI.
pub fn decode(data string) string {
	return unsafe { C.webui_decode(&char(data.str)).vstring() }
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

// set_profile sets the web browser profile to use.
// An empty `name` and `path` means the default user profile.
// Needs to be called before `webui_show()`.
pub fn (w Window) set_profile(name string, path string) {
	C.webui_set_profile(w, &char(name.str), &char(path.str))
}

// get_url returns the full current URL
pub fn (w Window) get_url() string {
	return unsafe { (&char(C.webui_get_url(w))).vstring() }
}

// navigate navigates to a specified URL
pub fn (w Window) navigate(url string) {
	C.webui_navigate(w, &char(url.str))
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

// get_arg parses the JavaScript argument into a V data type.
pub fn (e &Event) get_arg[T]() !T {
	if e.size == 0 {
		return error('`${e.element}` did not receive an argument.')
	}
	c_event := e.c_struct()
	return $if T is int {
		int(C.webui_get_int(c_event))
	} $else $if T is i64 {
		C.webui_get_int(c_event)
	} $else $if T is string {
		e.data
	} $else $if T is bool {
		C.webui_get_bool(c_event)
	} $else {
		json.decode(T, e.data) or { return error('Failed decoding `${T.name}` argument. ${err}') }
	}
}
