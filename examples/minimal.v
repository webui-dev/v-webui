import vwebui as ui

mut w := ui.new_window()
w.show('<html><head><script src="/webui.js"></script></head>Hello</html>')!
ui.wait()
