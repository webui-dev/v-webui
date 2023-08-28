import vwebui as ui
import encoding.base64
import os
import json

fn close(e &ui.Event) {
	ui.exit()
}

fn open(e &ui.Event) {
	str := e.string()
	if str == '' {
		e.window.run("webui.call('Open', prompt`File Location`)")
		return
	} else if str == 'null' {
		return
	}
	file := e.string()
	if file != '' {
		file_content := os.read_file(file) or {
			println('Failed to read file: ${file}')
			''
		}

		encoded_file := base64.encode_str(file)
		encoded_file_content := base64.encode_str(file_content)
		e.window.run('SetFile`${encoded_file}`')
		e.window.run('addText`${encoded_file_content}`')
		e.window.run('window.opened_file = `${file}`')
	}
}

struct Save {
	file    string
	content string
}

fn save(e &ui.Event) {
	resp := json.decode(Save, e.string()) or {
		e.window.run("ui.call('Save', JSON.stringify({file:window.opened_file,content:window.atob`${base64.encode_str(e.string())}`}))")
		return
	}
	os.write_file(resp.file, resp.content) or { panic(err) }
}

fn main() {
	w := ui.new_window()

	w.set_root_folder(@VMODROOT)

	w.bind('Open', open)
	w.bind('Save', save)
	w.bind('Close', close)
	w.show('ui/MainWindow.html') or { panic(err) }

	ui.wait()
}
