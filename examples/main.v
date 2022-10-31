/*
    WebUI Library 2.x
    V Example
    Licensed under GNU General Public License v3.0.
    Copyright (C)2022 Hassan DRAGA <https://github.com/hassandraga>.
    Copyright (C)2022 Mehmet Ali <https://github.com/malisipi>.
*/

import malisipi.vwebui as webui

// Check the password function
fn check_the_password(e &webui.Event) {
	// This function get called every time the user click on "MyButton1"
	mut js:=webui.Javascript {timeout: 3}
	js.set_script("return document.getElementById(\"MyInput\").value;")

	// Run the JavaScript on the UI (Web Browser)
	webui.script(e.window, &js)
	
	// Check if there is any JavaScript error
	if js.result.error {
		println("JavaScript Error:\n"+js.result.result())
		return
	}

	// Get the password
	password := js.result.result()
	println("Password: "+password)
	
	// Check the password
	if password == "123456" {
		// Correct password
		js.set_script("alert('Good. Password is correct.')")
		webui.script(e.window, &js)
	}
	else {
		// Wrong password
		js.set_script("alert('Sorry. Wrong password.')")
		webui.script(e.window, &js)
	}
	
	// Free data resources
	webui.free_script(&js)
}

fn close_the_application(e &webui.Event){
	// Close all opened windows
	webui.exit()
}

// Create a window
mut my_window := webui.new_window()

// UI HTML
my_html := "<!DOCTYPE html>\
<html><head><title>WebUI 2 - C99 Example</title>\
<style>body{color: white; background: #0F2027;\
background: -webkit-linear-gradient(to right, #2C5364, #203A43, #0F2027);\
background: linear-gradient(to right, #2C5364, #203A43, #0F2027);\
text-align:center; font-size: 18px; font-family: sans-serif;}</style></head><body>\
<h1>WebUI 2 - C99 Example</h1><br>\
<input type=\"password\" id=\"MyInput\"><br><br>\
<button id=\"MyButton1\">Check Password</button> - <button id=\"MyButton2\">Exit</button>\
</body></html>"

// Bind HTML elements with functions
webui.bind(my_window, "MyButton1", check_the_password)
webui.bind(my_window, "MyButton2", close_the_application)

// Show the window
if !webui.show(my_window, my_html, webui.browser_chrome){	// Run the window on Chrome
	webui.show(my_window, my_html, webui.browser_any)	// If not, run on any other installed web browser
}

// Wait until all windows get closed
webui.wait()
