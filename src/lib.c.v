module vwebui

#include "@VMODROOT/webui/webui.h"

#flag -L@VMODROOT/webui -lwebui-2-static
#flag linux -lpthread -lm
#flag darwin -lpthread -lm
#flag windows -lwebui-2 -lws2_32

struct C.webui_event_t {
pub:
	window       Window    // The window object number
	event_type   EventType // Event type
	element      &char     // HTML element ID
	data         &char     // JavaScript data
	size         usize     // JavaScript data len
	event_number usize     // Internal WebUI
}

// -- Definitions ---------------------
fn C.webui_new_window() Window
fn C.webui_new_window_id(win_id Window)
fn C.webui_get_new_window_id() Window
fn C.webui_bind(win Window, elem &char, func fn (&Event)) Window
fn C.webui_show(win Window, content &char) bool
fn C.webui_show_browser(win Window, content &char, browser Browser) bool
fn C.webui_set_kiosk(win Window, kiosk bool)
fn C.webui_wait()
fn C.webui_close(win Window)
fn C.webui_destroy(win Window)
fn C.webui_exit()
fn C.webui_set_root_folder(win Window, path &char)
fn C.webui_set_default_root_folder(path &char)
fn C.webui_set_file_handler(win Window, handler fn (file_name &char, length int)) // currently unused

// -- Other ---------------------------
fn C.webui_is_shown(win Window) bool
fn C.webui_set_timeout(second usize)
fn C.webui_set_icon(win Window, icon &char, icon_type &char)
fn C.webui_set_multi_access(win Window, status bool)

// -- JavaScript ----------------------
fn C.webui_run(win Window, script &char)
fn C.webui_script(win Window, script &char, timeout usize, buffer &char, buffer_length usize) bool
fn C.webui_set_runtime(win Window, runtime Runtime)
fn C.webui_get_int(e &Event) i64
fn C.webui_get_string(e &Event) &char
fn C.webui_get_bool(e &Event) bool
fn C.webui_return_int(e &Event, n i64)
fn C.webui_return_string(e &Event, s &char)
fn C.webui_return_bool(e &Event, b bool)
fn C.webui_encode(str &char) &char // currently unused
fn C.webui_decode(str &char) &char // currently unused
fn C.webui_free(ptr voidptr) // currently unused
fn C.webui_malloc(size usize) voidptr // currently unused
fn C.webui_send_raw(size Window, func &char, raw voidptr, size usize) // currently unused
fn C.webui_set_hide(win Window, status bool) // currently unused

// -- Interface -----------------------
fn C.webui_interface_bind(win Window, element &char, func fn (win Window, event_type EventType, element &char, data &char, data_size usize, event_num usize)) usize // currently unused
fn C.webui_interface_set_response(win Window, event_num usize, resp &char) // currently unused
fn C.webui_interface_is_app_running() bool
fn C.webui_interface_get_window_id(win Window) Window
fn C.webui_interface_get_bind_id(win Window, element &char) Window
