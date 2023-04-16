/*
    WebUI Library 2.x
    V Example
    Licensed under GNU General Public License v3.0.
    Copyright (C)2022 Hassan DRAGA <https://github.com/hassandraga>.
    Copyright (C)2022-2023 Mehmet Ali Şipi <https://github.com/malisipi>.
*/

import malisipi.vwebui as webui

fn check_the_password(e &webui.Event_t) { // Check the password function
    mut js := webui.Script_t {timeout: 3} // This function get called every time the user click on "MyButton1"
    js.set_script("return document.getElementById(\"MyInput\").value;")

    e.window.script(&js)
    
    if js.result.error { // Check if there is any JavaScript error
        println("JavaScript Error:\n"+js.result.get())
        return
    }

    password := js.result.get() // Get the password
    println("Password: "+password)
    
    if password == "123456" { // Check the password
        js.set_script("alert('Good. Password is correct.')") // Correct password
    } else {
        js.set_script("alert('Sorry. Wrong password.')") // Wrong password
    }
    e.window.script(&js)
    
    js.cleanup() // Free data resources
}

fn close_the_application(e &webui.Event_t) { // Close all opened windows
    webui.exit()
}

mut my_window := webui.new_window() // Create a window

// UI HTML
my_html := ('
    <!DOCTYPE html>
    <html><head><title>WebUI 2 - V Example</title>
    <style>body{color: white; background: #0F2027;
    background: -webkit-linear-gradient(to right, #2C5364, #203A43, #0F2027);
    background: linear-gradient(to right, #2C5364, #203A43, #0F2027);
    text-align:center; font-size: 18px; font-family: sans-serif;}</style></head><body>
    <h1>WebUI 2 - V Example</h1><br>
    <input type=\"password\" id=\"MyInput\"><br><br>
    <button id=\"MyButton1\">Check Password</button> - <button id=\"MyButton2\">Exit</button>
    </body></html>
')

// Bind HTML elements with functions
my_window.bind("MyButton1", check_the_password)
my_window.bind("MyButton2", close_the_application)

// Show the window
if !my_window.show(my_html) { // Run the window
    panic("The browser(s) was failed") // If not, print a error info
}

// Wait until all windows get closed
webui.wait()
