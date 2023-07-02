import vwebui as webui
import encoding.base64
import os
import json

fn close(e &webui.Event) webui.Response {
	webui.exit()
	return 0
}

fn open(e &webui.Event) webui.Response {
	if e.data.string == '' {
		e.window.run("webui_fn('Open', prompt`File Location`)")
		return 0
	} else if e.data.string == 'null' {
		return 0
	}
	file := e.data.string
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
	return 0
}

struct Save {
	file    string
	content string
}

fn save(e &webui.Event) webui.Response {
	resp := json.decode(Save, e.data.string) or {
		e.window.run("webui_fn('Save', JSON.stringify({file:window.opened_file,content:window.atob`${base64.encode_str(e.data.string)}`}))")
		return 0
	}
	os.write_file(resp.file, resp.content) or { panic(err) }
	return 0
}

main_window := webui.new_window()

main_window.bind('Open', open)
	.bind('Save', save)
	.bind('Close', close)
	.show('ui/MainWindow.html')

webui.wait()
