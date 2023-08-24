module vwebui

#include "@VMODROOT/webui/webui.h"

#flag -L@VMODROOT/webui -lwebui-2-static-x64 -lpthread -lm
#flag windows @VMODROOT/webui/webui-2-x64.dll -lws2_32
#flag -DNDEBUG -DNO_CACHING -DNO_CGI -DNO_SSL -DUSE_WEBSOCKET -DMUST_IMPLEMENT_CLOCK_GETTIME

// Debug
$if webui_log ? {
	#flag -DWEBUI_LOG
}

// -- Definitions ---------------------
fn C.webui_new_window() Window
fn C.webui_new_window_id(win_id Window)
fn C.webui_get_new_window_id() Window
fn C.webui_bind(win Window, elem &char, func fn (&CEvent)) Window
fn C.webui_show(win Window, content &char) bool
fn C.webui_show_browser(win Window, content &char, browser Browser) bool
fn C.webui_set_kiosk(win Window, kiosk bool)
fn C.webui_wait()
fn C.webui_close(win Window)
fn C.webui_destroy(win Window)
fn C.webui_exit()
fn C.webui_set_root_folder(win Window, path &char)
fn C.webui_set_file_handler(win Window, handler fn (file_name &char, length int)) // currently unused

// -- Definitions ---------------------
fn C.webui_is_shown(win Window) bool
fn C.webui_set_timeout(second u64)
fn C.webui_set_icon(win Window, icon &char, icon_type &char)
fn C.webui_set_multi_access(win Window, status bool)

// -- JavaScript ----------------------
fn C.webui_run(win Window, script &char)
fn C.webui_script(win Window, script &char, timeout u64, buffer &char, buffer_length u64) bool
fn C.webui_set_runtime(win Window, runtime Runtime)
fn C.webui_get_int(e &CEvent) i64
fn C.webui_get_string(e &CEvent) &char
fn C.webui_get_bool(e &CEvent) bool
fn C.webui_return_int(e &CEvent, n i64)
fn C.webui_return_string(e &CEvent, s &char)
fn C.webui_return_bool(e &CEvent, b bool)

fn C.webui_encode(str &char) &char // currently unused
fn C.webui_decode(str &char) &char // currently unused
fn C.webui_free(ptr voidptr) // currently unused
fn C.webui_malloc(size u64) voidptr // currently unused
fn C.webui_send_raw(size Window, func &char, raw voidptr, size u64) // currently unused
fn C.webui_set_hide(win Window, status bool) // currently unused

// -- Interface -----------------------
fn C.webui_interface_bind(win Window, element &char, func fn (win Window, event_type EventType, element &char, data &char, data_size u64, event_num u64)) u64 // currently unused
fn C.webui_interface_set_response(win Window, event_num u64, resp &char) // currently unused
fn C.webui_interface_is_app_running() bool
fn C.webui_interface_get_window_id(win Window) Window
fn C.webui_interface_get_bind_id(win Window, element &char) Window
