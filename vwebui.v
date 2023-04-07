module vwebui

#include "@VMODROOT/webui/mongoose.h"
#flag @VMODROOT/webui/mongoose.c
#include "@VMODROOT/webui/webui.h"
#flag @VMODROOT/webui/webui.c
#flag windows -lws2_32
#flag windows -luser32

pub const (
	event_connected = 1
	event_multi_connection = 2
	event_unwanted_connection = 3
	event_disconnected = 4
	event_mouse_click = 5
	event_navigation = 6
	event_callback = 7
)

// C Functions & Typedefs

pub struct C.webui_window_core_t {
pub mut:
	window_number        u32
	server_running       bool
	connected            bool
	server_handled       bool
	multi_access         bool
	server_root          bool
	server_port          u32
	url                  &char
	html                 &char
	html_cpy             &char
	icon                 &char
	icon_type            &char
	CurrentBrowser       u32
	browser_path         &char
	profile_path         &char
	connections          u32
	runtime              u32
	detect_process_close bool
	has_events           bool
}

pub struct C.webui_window_t {
pub mut:
	core C.webui_window_core_t
	path &char
}

pub struct C.webui_event_t {
pub mut:
	window_id    u32
	element_id   u32
	element_name &char
	window       &C.webui_window_t
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

pub struct C.webui_script_t {
pub mut:
	script  &char
	timeout u32
	result  C.webui_javascript_result_t
}

pub struct C.webui_cb_t {
pub mut:
	win               &C.webui_window_t
	webui_internal_id &char
	element_name      &char
	data              voidptr
	data_len          u32
	event_type        int
}

pub struct C.webui_cmd_async_t {
pub mut:
	win &C.webui_window_t
	cmd &char
}

pub struct C.webui_custom_browser_t {
pub mut:
	app       &char
	arg       &char
	auto_link bool
}

pub struct C.webui_runtime_t {
pub mut:
	none_  u32
	deno   u32
	nodejs u32
}

pub struct C.webui_t {
pub mut:
	servers                u32
	connections            u32
	process                u32
	custom_browser         &C.webui_custom_browser_t
	wait_for_socket_window bool
	html_elements          [1024]&char
	used_ports             [1024]u32
	last_window            u32
	startup_timeout        u32
	use_timeout            bool
	timeout_extra          bool
	exit_now               bool
	run_responses          [1024]&char
	run_done               [1024]bool
	run_error              [1024]bool
	run_last_id            u32
	browser                C.webui_browser_t
	runtime                C.webui_runtime_t
	initialized            bool
	executable_path &char
	ptr_list        [1024]voidptr
	ptr_position    u32
	ptr_size        [1024]usize
}

fn C.webui_new_window() &C.webui_window_t

fn C.webui_bind(win &C.webui_window_t, element &char, func fn (&C.webui_event_t)) u32

fn C.webui_show(win &C.webui_window_t, content &char) bool

fn C.webui_wait()

fn C.webui_close(win &C.webui_window_t)

fn C.webui_exit()

fn C.webui_script(win &C.webui_window_t, script &C.webui_script_t)

fn C.webui_script_cleanup(script &C.webui_script_t)

fn C.webui_script_runtime(win &C.webui_window_t, runtime u32)

fn C.webui_get_int(e &C.webui_event_t) i64

fn C.webui_get_string(e &C.webui_event_t) &char

fn C.webui_get_bool(e &C.webui_event_t) bool

fn C.webui_return_int(e &C.webui_event_t, n i64)

fn C.webui_return_string(e &C.webui_event_t, s &char)

fn C.webui_return_bool(e &C.webui_event_t, b bool)

fn C.webui_new_server(win &C.webui_window_t, path &char) &char

fn C.webui_open(win &C.webui_window_t, url &char, browser u32) bool

fn C.webui_is_any_window_running() bool

fn C.webui_is_app_running() bool

fn C.webui_is_shown(win &C.webui_window_t) bool

fn C.webui_set_timeout(second u32)

fn C.webui_set_icon(win &C.webui_window_t, icon_s &char, type_s &char)

fn C.webui_multi_access(win &C.webui_window_t, status bool)

fn C.webui_clean_mem(p voidptr)

pub struct C.webui_script_interface_t {
	script  &char
	timeout u32
	error   bool
	length  u32
	data    &char
}

fn C.webui_bind_interface(win &C.webui_window_t, element &char, func fn (u32, u32, &char, &C.webui_window_t, &char, &&char)) u32

fn C.webui_script_interface(win &C.webui_window_t, script &char, timeout u32, error &bool, length &u32, data &&u8)

fn C.webui_script_interface_struct(win &C.webui_window_t, js_int &C.webui_script_interface_t)

// V Interface

pub type Webui_function = fn(details &C.webui_event_t)
pub type Window_t = C.webui_window_t
pub type Event_t = C.webui_event_t
pub type Script_t = C.webui_script_t

pub fn (mut javascript C.webui_script_t) set_script (script string) {
	javascript.script = script.str
}

pub fn (window &C.webui_window_t) script (javascript &C.webui_script_t) {
    C.webui_script(window, javascript)
}

pub fn (javascript &C.webui_script_t) cleanup () {
    C.webui_script_cleanup(javascript)
}

pub fn (javascript_result C.webui_javascript_result_t) get () string {
	unsafe {
		return javascript_result.data.vstring()
	}
	return ""
}

pub fn new_window() &C.webui_window_t {
	return C.webui_new_window()
}

pub fn wait() {
	C.webui_wait()
}

pub fn (window &C.webui_window_t) show (html_code string) bool {
	return C.webui_show(window, html_code.str)
}

pub fn exit() {
	C.webui_exit()
}

pub fn (window &C.webui_window_t) bind (button_id string, funct Webui_function) {
	C.webui_bind(window, button_id.str, funct)
}
