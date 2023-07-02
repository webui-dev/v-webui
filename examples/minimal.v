import vwebui as webui

mut my_window := webui.new_window()
my_window.show('<html>Hello</html>')
webui.wait()
