module vwebui

#include "@VMODROOT/webui/mongoose.h"
#flag @VMODROOT/webui/mongoose.c
#include "@VMODROOT/webui/webui.h"
#flag @VMODROOT/webui/webui.c
#flag windows -lws2_32
#flag windows -luser32

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
)

// Typedefs of struct

pub type Window_t = voidptr
pub type Webui_function = fn(details &C.webui_event_t)
pub type Event_t = C.webui_event_t

// C Functions & Typedefs

pub struct C.webui_event_t {
pub mut:
	window_id    u32
	element_id   u32
	element_name &char
	window       Window_t
	data         voidptr
	response     voidptr
	@type        int // It's not my fault. `type` is a keyword of V.
}

pub struct C.webui_javascript_result_t {
pub mut:
	error  bool
	length u32
	data   &char
}

fn C.webui_new_window() Window_t

fn C.webui_bind(win Window_t, element &char, func fn (&C.webui_event_t)) u32

fn C.webui_show(win Window_t, content &char) bool

fn C.webui_show_browser(win Window_t, url &char, browser u32) bool

fn C.webui_wait()

fn C.webui_close(win Window_t)

fn C.webui_exit()

fn C.webui_is_shown(win Window_t) bool

fn C.webui_set_timeout(second u32)

fn C.webui_set_icon(win Window_t, icon_s &char, type_s &char)

fn C.webui_multi_access(win Window_t, status bool)

// ? fn C.webui_run(win Window_t, script &char)

fn C.webui_script(win Window_t, script &char, timeout int, buffer &char, size_buffer int)

// fn C.webui_set_runtime(win Window_t, script &char)

fn C.webui_get_int(e &C.webui_event_t) i64

fn C.webui_get_string(e &C.webui_event_t) &char

fn C.webui_get_bool(e &C.webui_event_t) bool

fn C.webui_return_int(e &C.webui_event_t, n i64)

fn C.webui_return_string(e &C.webui_event_t, s &char)

fn C.webui_return_bool(e &C.webui_event_t, b bool)

fn C.webui_bind_interface(win Window_t, element &char, func fn (u32, u32, &char, Window_t, &char, &&char)) u32

// ? fn C.webui_interface_set_response(ptr &char, response &char)

fn C.webui_is_app_running() bool

fn C.webui_interface_get_window_id(win Window_t) u32

// V Interface

pub fn (window Window_t) script (javascript string, timeout int, size_buffer int) string {
	response := &char(" ".repeat(size_buffer).str)
    C.webui_script(window, &char(javascript.str), timeout, response, size_buffer)
	return unsafe { response.vstring() }
}

struct WebuiResponseData {
pub mut:
	string	string
	int		int
	bool	bool
}

pub fn (event &C.webui_event_t) get () WebuiResponseData {
    str := unsafe { C.webui_get_string(event).vstring() }
    return WebuiResponseData {
        string: str
        int: str.int()
        bool: str == "true"
    }
}

type WebuiResponseReturn = int | string | bool

pub fn (event &C.webui_event_t) @return (response WebuiResponseReturn) {
    match response {
        string {
            C.webui_return_string(event, &char(response.str))
    	}
        int {
            C.webui_return_int(event, response)
    	}
        bool {
            C.webui_return_bool(event, int(response))
    	}
    }
}

pub fn new_window() Window_t {
	return C.webui_new_window()
}

pub fn wait() {
	C.webui_wait()
}

pub fn (window Window_t) show (html_code string) bool {
	return C.webui_show(window, html_code.str)
}

pub fn (window Window_t) close () {
	C.webui_close(window)
}

pub fn (window Window_t) open (html_code string, browser int) bool {
	return C.webui_show_browser(window, html_code.str, browser)
}

pub fn exit() {
	C.webui_exit()
}

pub fn (window Window_t) bind (button_id string, funct Webui_function) {
	C.webui_bind(window, button_id.str, funct)
}
