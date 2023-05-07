// v install https://github.com/malisipi/vwebui
import malisipi.vwebui as webui

mut my_window := webui.new_window()
my_window.set_kiosk(true)
my_window.show("<html>A kiosk example</html>")
webui.wait()
