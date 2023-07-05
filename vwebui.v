/*
V-WebUI 2.3.0
https://github.com/malisipi/vwebui
Copyright (c) 2023 Mehmet Ali.
Licensed under MIT License.
All rights reserved.
*/

[translated]
module vwebui

// WebUI Core

#include "@VMODROOT/webui/webui.h"

#flag -L@VMODROOT/webui -lwebui-2-static-x64 -lpthread -lm
#flag windows @VMODROOT/webui/webui-2-x64.dll -lws2_32
#flag -DNDEBUG -DNO_CACHING -DNO_CGI -DNO_SSL -DUSE_WEBSOCKET -DMUST_IMPLEMENT_CLOCK_GETTIME

// Debug
$if webui_log ? {
	#flag -DWEBUI_LOG
}

// Consts
__global (
	function_list map[u64]map[u64]Function
)

pub enum event as u64 {
	disconnected = 0
	connected = 1
	multi_connection = 2
	unwanted_connection = 3
	mouse_click = 4
	navigation = 5
	callback = 6
}

pub enum browser as u64 {
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

pub enum runtime as u64 {
	runtime_none = 0
	runtime_deno = 1
	runtime_nodejs = 2
}

// Typedefs of struct

pub type Window = u64

pub struct C.webui_event_t {
pub mut:
	window       Window // Pointer to the window object
	event_type   u64    // Event type
	element      &char  // HTML element ID
	data         &char  // JavaScript data
	event_number u64    // To set the callback response
}

pub type CEvent = C.webui_event_t
pub type CFunction = fn (e &CEvent)

pub struct Event {
pub mut:
	window       Window // Pointer to the window object
	event_type   event  // Event type
	element      string // HTML element ID
	data         WebuiResponseData // JavaScript data
	event_number u64 // To set the callback response
}

pub type Function = fn (e &Event) Response

// C Functions

fn C.webui_new_window() Window
fn C.webui_new_window_id(win_id u64)
fn C.webui_bind(win Window, element &char, func fn (&CEvent)) u64
fn C.webui_show(win Window, content &char) bool
fn C.webui_show_browser(win Window, content &char, browser u64) bool
fn C.webui_wait()
fn C.webui_close(win Window)
fn C.webui_destroy(win Window)
fn C.webui_exit()
fn C.webui_is_shown(win Window) bool
fn C.webui_set_timeout(second u64)
fn C.webui_set_icon(win Window, icon &char, icon_type &char)
fn C.webui_set_multi_access(win Window, status bool)
fn C.webui_run(win Window, script &char)
fn C.webui_script(win Window, script &char, timeout u64, buffer &char, size_buffer u64)
fn C.webui_set_kiosk(win Window, kiosk bool)
fn C.webui_set_runtime(win Window, runtime u64)
fn C.webui_get_int(e &CEvent) i64
fn C.webui_get_string(e &CEvent) &char
fn C.webui_get_bool(e &CEvent) bool
fn C.webui_return_int(e &CEvent, n i64)
fn C.webui_return_string(e &CEvent, s &char)
fn C.webui_return_bool(e &CEvent, b bool)
fn C.webui_interface_is_app_running() bool
fn C.webui_interface_get_window_id(win Window) u64
fn C.webui_interface_get_bind_id(win Window, element &char) u64
fn C.webui_get_new_window_id() u64

// V Interface

pub fn (window Window) script(javascript string, timeout u64, size_buffer int) string {
	response := &char(' '.repeat(size_buffer).str)
	C.webui_script(window, &char(javascript.str), timeout, response, size_buffer)
	return unsafe { response.vstring() }
}

// Get
struct WebuiResponseData {
pub mut:
	string string
	int    int
	bool   bool
}

pub fn (e &CEvent) get() WebuiResponseData {
	str := unsafe { (&char(C.webui_get_string(e))).vstring() }
	return WebuiResponseData{
		string: str
		int: str.int()
		bool: str == 'true'
	}
}

// Return
type Response = bool | int | string

pub fn (e &CEvent) @return(response Response) {
	match response {
		string {
			C.webui_return_string(e, &char(response.str))
		}
		int {
			C.webui_return_int(e, i64(response))
		}
		bool {
			C.webui_return_bool(e, int(response))
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
pub fn (window Window) show_browser(content string, browser_id browser) bool {
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
pub fn (window Window) set_runtime(runtime runtime) {
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

// Set the window in Kiosk mode (Full screen)
pub fn (window Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(window, kiosk)
}

fn native_event_handler(e &CEvent) {
	unsafe {
		bind_id := C.webui_interface_get_bind_id(e.window, e.element)
		win_id := C.webui_interface_get_window_id(e.window)
		func := function_list[win_id][bind_id]
		resp := func(Event{
			window: e.window
			event_type: event(e.event_type)
			element: e.element.vstring()
			data: e.get()
			event_number: e.event_number
		})
		e.@return(resp)
	}
}

fn native_raw_event_handler(e &CEvent) {
	native_event_handler(&CEvent{
		window: e.window
		event_type: e.event_type
		element: c''
		data: e.data
		event_number: e.event_number
	})
}

// Bind a specific html element click event with a function. Empty element means all events.
pub fn (window Window) bind(element string, func Function) Window {
	bind_id := if element != '' {
		C.webui_bind(window, &char(element.str), native_event_handler)
	} else {
		C.webui_bind(window, &char(element.str), native_raw_event_handler)
	}
	function_list[C.webui_interface_get_window_id(window)][bind_id] = func
	return window
}

// Set the maximum time in seconds to wait for browser to start
pub fn set_timeout(timeout u64) {
	C.webui_set_timeout(timeout)
}

pub fn get_window(win_id u64) Window {
	return Window(win_id)
}

pub fn new_window_by_id(win_id u64) Window {
	C.webui_new_window_id(win_id)
	return get_window(win_id)
}

[deprecated: 'use get_new_window_id instead']
pub fn new_id() u64 {
	return C.webui_get_new_window_id()
}

pub fn get_new_window_id() Window {
	return C.webui_get_new_window_id()
}
