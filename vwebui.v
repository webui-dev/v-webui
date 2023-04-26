/*
  V-WebUI 2.2.0
  https://github.com/malisipi/vwebui
  Copyright (c) 2023 Mehmet Ali.
  Licensed under GNU General Public License v2.0.
  All rights reserved.
*/

module vwebui

// WebUI Core

#include "@VMODROOT/webui/mongoose.h"
#include "@VMODROOT/webui/webui.h"
#include "@VMODROOT/webui/webui_core.h"
#flag @VMODROOT/webui/mongoose.c
#flag @VMODROOT/webui/webui.c
#flag windows -lws2_32 -lAdvapi32 -luser32 -DWEBUI_NO_TLHELPER32

// Consts

pub const (
	event_disconnected = 0
	event_connected = 1
	event_multi_connection = 2
	event_unwanted_connection = 3
	event_mouse_click = 4
	event_navigation = 5
	event_callback = 6
	browser_any = 0
	browser_chrome = 1
	browser_firefox = 2
	browser_edge = 3
	browser_safari = 4
	browser_chromium = 5
	browser_opera = 6
	browser_brave = 7
	browser_vivaldi = 8
	browser_epic = 9
	browser_yandex = 10
	runtime_none = 0
	runtime_deno = 1
	runtime_nodejs = 2
)

// Typedefs of struct

pub type WebuiWindow = voidptr
pub struct C.webui_event_t {
	pub mut:
	window		WebuiWindow // Pointer to the window object
	event_type	u32 // Event type :)
	element		&char // HTML element ID
	data		&char // JavaScript data
	response	&char // Callback response
}
pub type WebuiEvent = C.webui_event_t
pub type WebuiFunction = fn(e &WebuiEvent)

// C Functions

fn C.webui_new_window() WebuiWindow
fn C.webui_bind(win WebuiWindow, element &char, func fn (&WebuiEvent)) u32
fn C.webui_show(win WebuiWindow, content &char) bool
fn C.webui_show_browser(win WebuiWindow, content &char, browser u32) bool
fn C.webui_wait()
fn C.webui_close(win WebuiWindow)
fn C.webui_exit()
fn C.webui_is_shown(win WebuiWindow) bool
fn C.webui_set_timeout(second u32)
fn C.webui_set_icon(win WebuiWindow, icon &char, icon_type &char)
fn C.webui_multi_access(win WebuiWindow, status bool)
fn C.webui_run(win WebuiWindow, script &char)
fn C.webui_script(win WebuiWindow, script &char, timeout u32, buffer &char, size_buffer u32)
fn C.webui_set_runtime(win WebuiWindow, runtime u32)
fn C.webui_get_int(e &WebuiEvent) i64
fn C.webui_get_string(e &WebuiEvent) &char
fn C.webui_get_bool(e &WebuiEvent) bool
fn C.webui_return_int(e &WebuiEvent, n i64)
fn C.webui_return_string(e &WebuiEvent, s &char)
fn C.webui_return_bool(e &WebuiEvent, b bool)
fn C.webui_interface_is_app_running() bool
fn C.webui_interface_get_window_id(win WebuiWindow) u32

// V Interface

pub fn (window WebuiWindow) script (javascript string, timeout u32, size_buffer int) string {
	response := &char(" ".repeat(size_buffer).str)
    C.webui_script(window, &char(javascript.str), timeout, response, size_buffer)
	return unsafe { response.vstring() }
}

// Get
struct WebuiResponseData {
pub mut:
	string	string
	u32		u32
	bool	bool
}
pub fn (e &WebuiEvent) get () WebuiResponseData {
    str := unsafe { C.webui_get_string(e).vstring() }
    return WebuiResponseData {
        string: str
        u32: str.u32()
        bool: str == "true"
    }
}

// Return
type WebuiResponseReturn = u32 | string | bool
pub fn (e &WebuiEvent) @return (response WebuiResponseReturn) {
    match response {
        string {
            C.webui_return_string(e, &char(response.str))
    	}
        u32 {
            C.webui_return_int(e, i64(response))
    	}
        bool {
            C.webui_return_bool(e, int(response))
    	}
    }
}

// Create a new webui window object.
pub fn new_window() WebuiWindow {
	return C.webui_new_window()
}

// Wait until all opened windows get closed.
pub fn wait() {
	C.webui_wait()
}

// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.
pub fn (window WebuiWindow) show (content string) bool {
	return C.webui_show(window, content.str)
}

// Close a specific window.
pub fn (window WebuiWindow) close () {
	C.webui_close(window)
}

// Close all opened windows. webui_wait() will break.
pub fn exit() {
	C.webui_exit()
}

// Bind a specific html element click event with a function. Empty element means all events.
pub fn (window WebuiWindow) bind (element string, func WebuiFunction) {
	C.webui_bind(window, element.str, func)
}

// Set the maximum time in seconds to wait for browser to start
pub fn set_timeout(timeout u32){
	C.webui_set_timeout(timeout)
}
