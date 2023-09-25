import vwebui as ui
import os

fn close(e &ui.Event) {
	println('Exit.')
	ui.exit()
}

fn main() {
	w := ui.new_window()

	w.bind[voidptr]('__close-btn', close)

	w.set_root_folder(os.join_path(@VMODROOT, 'ui'))

	w.show_browser('index.html', .chromium_based) or {
		w.show('index.html')!
		eprintln('Warning: Install a Chromium-based web browser for an optimized experience.')
	}

	ui.wait()
}
