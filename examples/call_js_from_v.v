import vwebui as ui

// UI HTML
const doc = '<!DOCTYPE html>
<html>
	<head>
		<title>Call JavaScript from V Example</title>
		<style>
			body {
				background: linear-gradient(to left, #36265a, #654da9);
				color: AliceBlue;
				font: 16px sans-serif;
				text-align: center;
				margin-top: 30px;
			}
			button {
				margin: 5px 0 10px;
			}
		</style>
		<!-- Connect this window to the background app -->
		<script src="/webui.js"></script>
	</head>
	<body>
		<h1>WebUI - Call JavaScript from V</h1>
		<br>
		<button id="MyButton1">Count <span id="count">0<span></button>
		<br>
		<button id="MyButton2">Exit</button>
		<script>
			let count = document.getElementById("count").innerHTML;
			function SetCount(number) {
				document.getElementById("count").innerHTML = number;
				count = number;
			}
		</script>
	</body>
</html>'

fn my_function_count(e &ui.Event) {
	count := e.window.script('return count;') or { return }
	e.window.run('SetCount(${count.int() + 1});')
}

// Close all opened windows
fn my_function_exit(e &ui.Event) {
	ui.exit()
}

// Create a window
mut w := ui.new_window()

// Bind HTML elements to functions
w.bind('MyButton1', my_function_count)
w.bind('MyButton2', my_function_exit)

// Show the window, panic on fail
w.show(doc) or { panic(err) }

// Wait until all windows get closed
ui.wait()
