module vwebui

#include "@VMODROOT/webui/mongoose.h"
#flag @VMODROOT/webui/mongoose.c
#include "@VMODROOT/webui/webui.h"
#flag @VMODROOT/webui/webui.c
#flag windows -lws2_32
#flag windows -luser32

pub const (
    browser_any         = 0
    browser_chrome      = 1
    browser_firefox     = 2
    browser_edge        = 3
    browser_safari      = 4
    browser_chromium    = 5
    browser_custom      = 99
)

struct C.webui_window_t {}

struct C.webui_javascript_result_t {
    pub mut:
        error   bool
        length  int
        data    &char
}

struct C.webui_event_t {
    pub mut:
        window_id       int
        element_id      int
        element_name    &char
        window          &Window
}

struct C.webui_script_t {
    pub mut:
        script  &char
        timeout int
        result  C.webui_javascript_result_t
}

pub type Window     = C.webui_window_t
pub type Event      = C.webui_event_t
pub type Javascript = C.webui_script_t

pub fn (javascript_result C.webui_javascript_result_t) result () string {
    unsafe {
        return javascript_result.data.vstring()
    }
    return ""
}

pub fn (mut javascript C.webui_script_t) set_script (script string) {
    javascript.script = script.str
}

type Webui_function=fn(details &Event)

fn C.webui_new_window() &Window
fn C.webui_show(window &Window, html &char, browser int) bool
fn C.webui_wait()
fn C.webui_exit()
fn C.webui_is_shown(window &Window) bool
fn C.webui_bind(window &Window, id &char, Webui_function)
fn C.webui_script(window &Window, javascript &Javascript)
fn C.webui_script_cleanup(javascript &Javascript)

pub fn new_window() &Window {
    return C.webui_new_window()
}

pub fn show(window &Window, html_code string, browser int) bool {
    return C.webui_show(window, html_code.str, browser)
}

pub fn wait() {
    C.webui_wait()
}

pub fn exit() {
    C.webui_exit()
}

pub fn bind(window &Window, button_id string, funct Webui_function) {
    C.webui_bind(window, button_id.str, funct)
}

pub fn script(window &Window, javascript &Javascript) {
    C.webui_script(window, javascript)
}

pub fn script_cleanup(javascript &Javascript) {
    C.webui_script_cleanup(javascript)
}

pub fn is_shown(window &Window) bool {
    return C.webui_is_shown(window)
}
