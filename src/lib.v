// V-WebUI
//
// Is a lightweight portable lib that allows to use any web browser as a GUI,
// with V in the backend and HTML5 in the frontend.
//
// License: MIT
// Source: https://github.com/webui-dev/v-webui
//
// Copyright (c) 2023 Mehmet Ali.
// Copyright (c) 2023-2024 WebUI Contributors.
module vwebui

import json

// A Window number of a WebUI window.
pub type Window = usize

// A unique function ID returned by the bind event.
pub type Function = usize

// An Event which a V function receives that is called by javascript.
pub struct Event {
pub:
	window        Window    // The window object number
	event_type    EventType // Event type
	element       string    // HTML element ID
	event_number  usize     // Internal WebUI
	bind_id       usize     // Bind ID
	client_id     usize     // Client's unique ID
	connection_id usize     // Client's connection ID
	cookies       string    // Client's full cookies
}

@[params]
pub struct ScriptOptions {
pub:
	// The maximum buffer size for the script response.
	max_response_size usize = 8 * 1024
	// Timeout in seconds.
	timeout usize
}

@[params]
pub struct ShowOptions {
pub:
	// Wait for the window to be recognized as shown.
	await bool
	// Timeout in seconds.
	timeout usize = 10
}

@[params]
pub struct GetArgOptions {
pub:
	idx usize
}

pub enum EventType {
	disconnected = C.WEBUI_EVENT_DISCONNECTED
	connected    = C.WEBUI_EVENT_CONNECTED
	mouse_click  = C.WEBUI_EVENT_MOUSE_CLICK
	navigation   = C.WEBUI_EVENT_NAVIGATION
	callback     = C.WEBUI_EVENT_CALLBACK
}

pub enum Browser {
	no_browser     = C.NoBrowser
	any            = C.AnyBrowser
	chrome         = C.Chrome
	firefox        = C.Firefox
	edge           = C.Edge
	safari         = C.Safari
	chromium       = C.Chromium
	opera          = C.Opera
	brave          = C.Brave
	vivaldi        = C.Vivaldi
	epic           = C.Epic
	yandex         = C.Yandex
	chromium_based = C.ChromiumBased
	webview        = C.Webview
}

pub enum Runtime {
	@none  = C.None
	deno   = C.Deno
	nodejs = C.NodeJS
	bun    = C.Bun
}

pub enum Config {
	show_wait_connection  = C.show_wait_connection
	ui_event_blocking     = C.ui_event_blocking
	folder_monitor        = C.folder_monitor
	multi_client          = C.multi_client
	use_cookies           = C.use_cookies
	asynchronous_response = C.asynchronous_response
}

pub enum LoggerLevel {
	debug = C.WEBUI_LOGGER_LEVEL_DEBUG
	info  = C.WEBUI_LOGGER_LEVEL_INFO
	error = C.WEBUI_LOGGER_LEVEL_ERROR
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
			event_number: c_event.event_number
			bind_id: c_event.bind_id
			client_id: c_event.client_id
			connection_id: c_event.connection_id
			cookies: unsafe { if c_event.cookies != nil { c_event.cookies.vstring() } else { '' } }
		}
		// Call user callback function and return response.
		e.@return(func(e))
		C.GC_unregister_my_thread()
	})
}

// get_best_browser returns the recommended web browser ID to use.
// If a browser is already being used, it returns the same ID.
pub fn (w Window) get_best_browser() Browser {
	return C.webui_get_best_browser(w)
}

// show opens a window using embedded HTML, or a file.
// If the window is already open, it will be refreshed.
pub fn (w Window) show(content string, opts ShowOptions) ! {
	if !C.webui_show(w, &char(content.str)) {
		return error('error: failed to show window')
	}
	if opts.await {
		return w.await_shown(opts.timeout)
	}
}

// show_client opens a window for a single client using embedded HTML, or a file.
// If the window is already open, it will be refreshed.
pub fn (e &Event) show_client(content string) ! {
	if !C.webui_show_client(e.c_struct(), &char(content.str)) {
		return error('error: failed to show window for client')
	}
}

// show_browser opens a window using embedded HTML, or a file in a specified browser.
// If the window is already open, it will be refreshed.
pub fn (w Window) show_browser(content string, browser Browser, opts ShowOptions) ! {
	if !C.webui_show_browser(w, &char(content.str), browser) {
		return error('error: failed to show window in `${browser}`')
	}
	if opts.await {
		return w.await_shown(opts.timeout)
	}
}

// start_server starts only the local web server and returns the URL. No window will be shown.
pub fn (w Window) start_server(path string) string {
	return unsafe { (&char(C.webui_start_server(w, &char(path.str)))).vstring() }
}

// show_wv opens a WebView window using embedded HTML, or a file.
// If the window is already open, it will be refreshed.
pub fn (w Window) show_wv(content string, opts ShowOptions) ! {
	if !C.webui_show_wv(w, &char(content.str)) {
		return error('error: failed to show WebView window')
	}
	if opts.await {
		return w.await_shown(opts.timeout)
	}
}

// set_kiosk determines whether Kiosk mode (full screen) is enabled for the window.
pub fn (w Window) set_kiosk(kiosk bool) {
	C.webui_set_kiosk(w, kiosk)
}

// focus brings the window to the front and focuses it.
pub fn (w Window) focus() {
	C.webui_focus(w)
}

// set_custom_parameters adds user-defined web browser CLI parameters.
pub fn (w Window) set_custom_parameters(params string) {
	C.webui_set_custom_parameters(w, &char(params.str))
}

// set_high_contrast sets the window with high-contrast support.
pub fn (w Window) set_high_contrast(status bool) {
	C.webui_set_high_contrast(w, status)
}

// set_resizable sets whether the window frame is resizable or fixed.
// Works only on WebView windows.
pub fn (w Window) set_resizable(status bool) {
	C.webui_set_resizable(w, status)
}

// is_high_contrast returns whether the OS is using a high-contrast theme.
pub fn is_high_contrast() bool {
	return C.webui_is_high_contrast()
}

// browser_exist checks if a web browser is installed.
pub fn browser_exist(browser Browser) bool {
	return C.webui_browser_exist(browser)
}

// wait waits until all opened windows get closed.
pub fn wait() {
	C.webui_wait()
}

// wait_async waits asynchronously until all opened windows get closed.
// Returns true if more windows are still open, false otherwise.
// Note: In WebView mode, call this from the main thread.
pub fn wait_async() bool {
	return C.webui_wait_async()
}

// close closes the window. The window object will still exist.
pub fn (w Window) close() {
	C.webui_close(w)
}

// minimize minimizes a WebView window.
pub fn (w Window) minimize() {
	C.webui_minimize(w)
}

// maximize maximizes a WebView window.
pub fn (w Window) maximize() {
	C.webui_maximize(w)
}

// close_client closes a specific client connection.
pub fn (e &Event) close_client() {
	C.webui_close_client(e.c_struct())
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
pub fn (w Window) set_root_folder(path string) ! {
	if !C.webui_set_root_folder(w, &char(path.str)) {
		return error('error: failed to set root folder `${path}`')
	}
}

// set_root_folder sets the web-server root folder path for all windows.
pub fn set_root_folder(path string) ! {
	if !C.webui_set_default_root_folder(&char(path.str)) {
		return error('error: failed to set default root folder `${path}`')
	}
}

// set_browser_folder sets a custom browser folder path.
pub fn set_browser_folder(path string) {
	C.webui_set_browser_folder(&char(path.str))
}

// is_shown checks if the window is still running.
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
pub fn (w Window) set_size(width u32, height u32) {
	C.webui_set_size(w, width, height)
}

// set_minimum_size sets the minimum window size.
pub fn (w Window) set_minimum_size(width u32, height u32) {
	C.webui_set_minimum_size(w, width, height)
}

// set_position sets the window position.
pub fn (w Window) set_position(x u32, y u32) {
	C.webui_set_position(w, x, y)
}

// set_center centers the window on the screen.
// Call before `show()` for best results.
pub fn (w Window) set_center() {
	C.webui_set_center(w)
}

// set_profile sets the web browser profile to use.
// An empty `name` and `path` means the default user profile.
// Needs to be called before `webui_show()`.
pub fn (w Window) set_profile(name string, path string) {
	C.webui_set_profile(w, &char(name.str), &char(path.str))
}

// set_proxy sets the web browser proxy server to use.
// Needs to be called before `show()`.
pub fn (w Window) set_proxy(proxy_server string) {
	C.webui_set_proxy(w, &char(proxy_server.str))
}

// get_url returns the full current URL
pub fn (w Window) get_url() string {
	return unsafe { (&char(C.webui_get_url(w))).vstring() }
}

// open_url opens a URL in the native default web browser.
pub fn open_url(url string) {
	C.webui_open_url(&char(url.str))
}

// set_public allows a specific window address to be accessible from a public network.
pub fn (w Window) set_public(status bool) {
	C.webui_set_public(w, status)
}

// navigate navigates to a specified URL. All clients.
pub fn (w Window) navigate(url string) {
	C.webui_navigate(w, &char(url.str))
}

// navigate_client navigates to a specified URL for a single client.
pub fn (e &Event) navigate_client(url string) {
	C.webui_navigate_client(e.c_struct(), &char(url.str))
}

// clean frees all memory resources. Should be called only at the end.
pub fn clean() {
	C.webui_clean()
}

// delete_all_profiles deletes all local web-browser profiles folders.
pub fn delete_all_profiles() {
	C.webui_delete_all_profiles()
}

// delete_profile deletes a specific window web-browser local folder profile.
pub fn (w Window) delete_profile() {
	C.webui_delete_profile(w)
}

// get_parent_process_id returns the parent process ID of the current backend application.
pub fn (w Window) get_parent_process_id() usize {
	return C.webui_get_parent_process_id(w)
}

// get_child_process_id returns the child process ID created by the parent (the web browser window).
pub fn (w Window) get_child_process_id() usize {
	return C.webui_get_child_process_id(w)
}

// get_port returns the network port of a running window.
pub fn (w Window) get_port() usize {
	return C.webui_get_port(w)
}

// set_port sets a custom web-server network port for the window.
pub fn (w Window) set_port(port usize) ! {
	if !C.webui_set_port(w, port) {
		return error('error: port ${port} is not free')
	}
}

// get_free_port returns an available free network port.
pub fn get_free_port() usize {
	return C.webui_get_free_port()
}

// set_config controls the WebUI behaviour globally.
pub fn set_config(option Config, status bool) {
	C.webui_set_config(usize(option), status)
}

// set_event_blocking controls if UI events from this window are processed
// one at a time in a single blocking thread, or in new non-blocking threads.
pub fn (w Window) set_event_blocking(status bool) {
	C.webui_set_event_blocking(w, status)
}

// set_frameless makes a WebView window frameless.
pub fn (w Window) set_frameless(status bool) {
	C.webui_set_frameless(w, status)
}

// set_transparent makes a WebView window transparent.
pub fn (w Window) set_transparent(status bool) {
	C.webui_set_transparent(w, status)
}

// get_mime_type returns the HTTP mime type of a file.
pub fn get_mime_type(file string) string {
	return unsafe { (&char(C.webui_get_mime_type(&char(file.str)))).vstring() }
}

// == Javascript ==============================================================

// run executes JavaScript without waiting for the response. All clients.
pub fn (w Window) run(script string) {
	C.webui_run(w, &char(script.str))
}

// run_client executes JavaScript without waiting for the response. Single client.
pub fn (e &Event) run_client(script string) {
	C.webui_run_client(e.c_struct(), &char(script.str))
}

// script executes JavaScript and returns the response (Make sure the response buffer can hold the response).
// The default max_response_size is 8KiB.
pub fn (w Window) script(javascript string, opts ScriptOptions) !string {
	mut buffer := []u8{len: int(opts.max_response_size)}
	if !C.webui_script(w, &char(javascript.str), opts.timeout, &char(buffer.data), opts.max_response_size) {
		return error('error: failed to run script `${javascript}`: ${buffer.bytestr()}')
	}
	return unsafe { buffer.bytestr() }
}

// script_client executes JavaScript and returns the response for a single client.
// The default max_response_size is 8KiB.
pub fn (e &Event) script_client(javascript string, opts ScriptOptions) !string {
	mut buffer := []u8{len: int(opts.max_response_size)}
	if !C.webui_script_client(e.c_struct(), &char(javascript.str), opts.timeout, &char(buffer.data), opts.max_response_size) {
		return error('error: failed to run script `${javascript}`: ${buffer.bytestr()}')
	}
	return unsafe { buffer.bytestr() }
}

// set_runtime sets the runtime for .js and .ts files to Deno, Bun, or Nodejs.
pub fn (w Window) set_runtime(runtime Runtime) {
	C.webui_set_runtime(w, runtime)
}

// get_arg parses the JavaScript argument into a V data type.
pub fn (e &Event) get_arg[T](opts GetArgOptions) !T {
	c_event := e.c_struct()
	if C.webui_get_size_at(c_event, opts.idx) == 0 {
		return error('`${e.element}` did not receive an argument.')
	}
	idx := opts.idx // Additional declaration currently fixes builder error in comptime statements.
	return $if T is int {
		int(C.webui_get_int_at(c_event, idx))
	} $else $if T is i64 {
		C.webui_get_int_at(c_event, idx)
	} $else $if T is f64 {
		C.webui_get_float_at(c_event, idx)
	} $else $if T is string {
		unsafe { (&char(C.webui_get_string_at(c_event, idx))).vstring() }
	} $else $if T is bool {
		C.webui_get_bool_at(c_event, idx)
	} $else {
		json.decode(T, unsafe { (&char(C.webui_get_string_at(c_event, idx))).vstring() }) or {
			return error('error: failed to decode `${T.name}` argument: ${err}')
		}
	}
}

// get_last_error_number returns the last WebUI error code.
pub fn get_last_error_number() usize {
	return C.webui_get_last_error_number()
}

// get_last_error_message returns the last WebUI error message.
pub fn get_last_error_message() string {
	return unsafe { (&char(C.webui_get_last_error_message())).vstring() }
}
