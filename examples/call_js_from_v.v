import vwebui as ui

// UI HTML
const doc = '<!DOCTYPE html>
<html>
	<head>
		<title>Call JavaScript from V Example</title>
		<script src="webui.js"></script>
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
	</head>
	<body>
		<h1>WebUI - Call JavaScript from V</h1>
		<br>
		<button id="increment-js">Count <span id="count">0</span></button>
		<br>
		<button id="exit">Exit</button>
		<script>
			let count = document.getElementById("count").innerHTML;
			function SetCount(number) {
				document.getElementById("count").innerHTML = number;
				count = number;
			}
		</script>
	</body>
</html>'

fn my_function_count(e &ui.Event) voidptr {
	count := e.window.script('return count;') or { return ui.no_result }
	e.window.run('SetCount(${count.int() + 1});')
	return ui.no_result
}

// Close all opened windows.
fn my_function_exit(e &ui.Event) {
	ui.exit()
}

// Create a window.
mut w := ui.new_window()

// Bind HTML elements to functions.
w.bind('increment-js', my_function_count)
// Alternative way to bind a function that does not return a value to JS
// and omits the return in the function body.
w.bind[voidptr]('exit', my_function_exit)

// Show the window, panic on fail.
w.show(doc)!

// Wait until all windows get closed.
ui.wait()
