import vwebui as ui

fn check_the_password(e &ui.Event) ui.Response { // Check the password function
	password := e.window.script('return document.getElementById("MyInput").value;', 0,
		4096)
	println('Password: ' + password)

	if password == '123456' { // Check the password
		e.window.run("alert('Good. Password is correct.');") // Correct password
	} else {
		e.window.run("alert('Sorry. Wrong password.');") // Wrong password
	}
	return 0
}

fn close_the_application(e &ui.Event) ui.Response { // Close all opened windows
	ui.exit()
	return 0
}

// UI HTML
const doc = '<!DOCTYPE html>
<html>
	<head>
		<title>WebUI - Hello World Example</title>
		<style>
			body {
				background: linear-gradient(to left, #36265a, #654da9);
				color: AliceBlue;
				fontsize: 16px sans-serif;
				text-align: center;
				margin-top: 30px;
			}
			button {
				margin: 5px 0 10px;
			}
		</style>
	</head>
	<body>
		<h1>WebUI 2 - V Example</h1><br>
		<input type="password" id="MyInput"><br><br>
		<button id="MyButton1">Check Password</button> - <button id="MyButton2">Exit</button>
	</body>
</html>'

mut w := ui.new_window() // Create a window

// Bind HTML elements with functions
w.bind('MyButton1', check_the_password)
w.bind('MyButton2', close_the_application)

// Show the window
if !w.show(doc) { // Run the window
	panic('The browser(s) was failed') // If not, print a error info
}

// Wait until all windows get closed
ui.wait()
