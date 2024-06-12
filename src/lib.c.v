module vwebui

#include "@VMODROOT/src/webui/include/webui.h"
$if macos {
	#include "@VMODROOT/src/webui/src/webview/wkwebview.m"
}

#flag -I@VMODROOT/src/webui/include/ -DNDEBUG -DNO_CACHING -DNO_CGI -DUSE_WEBSOCKET
#flag @VMODROOT/src/webui/src/civetweb/civetweb.c
#flag @VMODROOT/src/webui/src/webui.c

#flag darwin -framework WebKit -framework Cocoa
#flag windows -lWs2_32 -lOle32

$if msvc {
	#flag -lAdvapi32 -lShell32 -lUser32
}
$if !tls ? {
	#flag -DNO_SSL
}
$if webui_log ? {
	#flag -DWEBUI_LOG
}

@[typedef]
struct C.webui_event_t {
pub:
	window       Window    // The window object number
	event_type   EventType // Event type
	element      &char     // HTML element ID
	event_number usize     // Internal WebUI
	bind_id      usize     // Bind ID
}

fn init() {
	// Handle await internally per window with user-defined timouts.
	C.webui_set_config(C.show_wait_connection, false)
}

// -- Definitions ---------------------
fn C.webui_new_window() Window
fn C.webui_new_window_id(win_id Window)
fn C.webui_get_new_window_id() Window
fn C.webui_bind(win Window, elem &char, func fn (&C.webui_event_t)) Function
fn C.webui_get_best_browser(win Window) Browser
fn C.webui_show(win Window, content &char) bool
fn C.webui_show_browser(win Window, content &char, browser Browser) bool
fn C.webui_show_wv(win Window, content &char) bool
fn C.webui_set_kiosk(win Window, kiosk bool)
fn C.webui_wait()
fn C.webui_close(win Window)
fn C.webui_destroy(win Window)
fn C.webui_exit()
fn C.webui_set_root_folder(win Window, path &char)
fn C.webui_set_default_root_folder(path &char)
fn C.webui_set_file_handler(win Window, handler fn (file_name &char, length int)) // not wrapped
fn C.webui_is_shown(win Window) bool
fn C.webui_set_timeout(second usize)
fn C.webui_set_icon(win Window, icon &char, icon_type &char)
fn C.webui_encode(str &char) &char
fn C.webui_decode(str &char) &char
fn C.webui_free(ptr voidptr) // not wrapped
fn C.webui_malloc(size usize) voidptr // not wrapped
fn C.webui_send_raw(size Window, func &char, raw voidptr, size usize) // not wrapped
fn C.webui_set_hide(win Window, status bool)
fn C.webui_set_size(win Window, width usize, height usize)
fn C.webui_set_position(win Window, x usize, y usize)
fn C.webui_set_profile(win Window, name &char, path &char)
fn C.webui_set_proxy(win Window, proxy_server &char)
fn C.webui_get_url(win Window) &char
fn C.webui_set_public(win Window, status bool)
fn C.webui_navigate(win Window, url &char)
fn C.webui_clean()
fn C.webui_delete_all_profiles()
fn C.webui_delete_profile(win Window)
fn C.webui_get_parent_process_id(win Window) usize
fn C.webui_get_child_process_id(win Window) usize
fn C.webui_set_port(win Window, port usize) bool
fn C.webui_set_config(option usize, status bool) bool
fn C.webui_set_tls_certificate(certificate_pem &char, private_key_pem &char) bool

// -- JavaScript ----------------------
fn C.webui_run(win Window, script &char)
fn C.webui_script(win Window, script &char, timeout usize, buffer &char, buffer_length usize) bool
fn C.webui_set_runtime(win Window, runtime Runtime)
fn C.webui_get_count(e &C.webui_event_t) usize
fn C.webui_get_int(e &C.webui_event_t) i64
fn C.webui_get_int_at(e &C.webui_event_t, idx usize) i64
fn C.webui_get_float(e &C.webui_event_t) f64
fn C.webui_get_float_at(e &C.webui_event_t, idx usize) f64
fn C.webui_get_string(e &C.webui_event_t) &char
fn C.webui_get_string_at(e &C.webui_event_t, idx usize) &char
fn C.webui_get_bool(e &C.webui_event_t) bool
fn C.webui_get_bool_at(e &C.webui_event_t, idx usize) bool
fn C.webui_get_size(e &C.webui_event_t) usize
fn C.webui_get_size_at(e &C.webui_event_t, idx usize) usize
fn C.webui_return_int(e &C.webui_event_t, n i64)
fn C.webui_return_string(e &C.webui_event_t, s &char)
fn C.webui_return_bool(e &C.webui_event_t, b bool)

// -- Interface ----------------------- // not wrapped
fn C.webui_interface_bind(win Window, element &char, func fn (win Window, event_type EventType, element &char, event_num usize, bind_id usize)) Function
fn C.webui_interface_set_response(win Window, event_num usize, resp &char)
fn C.webui_interface_is_app_running() bool
fn C.webui_interface_get_window_id(win Window) Window
