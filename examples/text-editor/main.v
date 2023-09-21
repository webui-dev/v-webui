import vwebui as ui
import encoding.base64
import os

[heap]
struct File {
mut:
	path string
}

fn (mut f File) open(e &ui.Event) {
	println('Open')
	file := e.string()
	if file == '' {
		e.window.run("webui.call('Open', prompt`File Location`)")
		return
	}
	file_content := os.read_file(file) or {
		println('Failed reading file: ${file}')
		return
	}
	f.path = file
	f.name = file.all_after_last(os.path_separator)
	e.window.run('SetFileModeExtension`${os.file_ext(f.name)}`')
	e.window.run('addText`${base64.encode_str(file_content)}`')
	e.window.run('changeWindowTitle`${f.name}`')
}

fn (f &File) save(e &ui.Event) {
	println('Save')
	content := e.string()
	if content == '' {
		return
	}
	os.write_file(f.path, content) or {
		eprintln(err)
		return
	}
}

fn close(e &ui.Event) {
	println('Close')
	ui.exit()
}

fn main() {
	w := ui.new_window()

	w.set_root_folder(@VMODROOT)

	mut file := File{}
	w.bind[voidptr]('Open', file.open)
	w.bind[voidptr]('Save', file.save)
	w.bind[voidptr]('Close', close)
	w.show('ui/index.html') or { panic(err) }

	ui.wait()
}
