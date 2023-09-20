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
	file := e.get_arg[string]() or {
		e.window.run("webui.call('Open', prompt`File Location`)")
		return
	}
	file_content := os.read_file(file) or {
		eprintln('Failed to read file: ${file}')
		return
	}
	f_name := file.all_after_last(os.path_separator)
	e.window.run('SetFileModeExtension`${os.file_ext(f_name)}`')
	e.window.run('addText`${base64.encode_str(file_content)}`')
	e.window.run('changeWindowTitle`${f_name}`')
	f.path = file
}

fn (f &File) save(e &ui.Event) {
	println('Save')
	content := e.get_arg[string]() or { return }
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
