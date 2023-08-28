import vwebui as ui

mut w := ui.new_window()
w.show('<html>Hello</html>') or {}
ui.wait()
