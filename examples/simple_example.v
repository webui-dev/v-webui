import vwebui as ui

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
		<script src="/webui.js"></script>
	</head>
	<body>
		<h1>WebUI 2 - V Example</h1><br>
		<input type="password" id="MyInput"><br><br>
		<button id="MyButton1">Check Password</button> - <button id="MyButton2">Exit</button>
	</body>
</html>'

fn check_the_password(e &ui.Event) voidptr {
	password := e.window.script('return document.getElementById("MyInput").value;') or {
		eprintln(err)
		return ui.no_result
	}
	println('Password: ' + password)

	if password == '123456' {
		e.window.run("alert('Good. Password is correct.');")
	} else {
		e.window.run("alert('Sorry. Wrong password.');")
	}
	return ui.no_result
}

// Close all opened windows
fn close_the_application(e &ui.Event) voidptr {
	ui.exit()
	return ui.no_result
}

// Create a window
mut w := ui.new_window()

// Bind HTML elements to functions
w.bind('MyButton1', check_the_password)
w.bind('MyButton2', close_the_application)

// Show the window, panic on fail
w.show(doc) or { panic(err) }

// Wait until all windows get closed
ui.wait()
