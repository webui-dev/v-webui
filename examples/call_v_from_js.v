import vwebui as ui

const doc = '<!DOCTYPE html>
<html>
	<head>
		<title>Call V from JavaScript Example</title>
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
		<h1>WebUI - Call V from JavaScript</h1>
		<br>
		<p>Call V functions with arguments (<em>See the logs in your terminal</em>)</p>
		<button onclick="webui.handleStr(\'Hello\', \'World\');">Call handle_str()</button>
		<br>
		<button onclick="webui.handleInt(123, 456, 789);">Call handle_int()</button>
		<br>
		<button onclick="webui.handleBool(true, false);">Call handle_bool()</button>
		<br>
		<p>Call a V function that returns a response</p>
		<button onclick="MyJS();">Call get_response()</button>
		<div>Double: <input type="text" id="my-input" value="2"></div>
		<script>
			async function MyJS() {
				const myInput = document.getElementById("my-input");
				const number = myInput.value;
				const result = await webui.getResponse(number);
				myInput.value = result;
			}
		</script>
	</body>
</html>'

// JavaScript: `webui.handleStr('Hello', 'World');`
fn handle_str(e &ui.Event) voidptr {
	str1 := e.get_arg[string]() or { return ui.no_result }
	str2 := e.get_arg[string](idx: 1) or { '' }

	println('handle_str 1: ${str1}') // Hello
	println('handle_str 2: ${str2}') // World

	return ui.no_result
}

// JavaScript: `webui.handleInt(123, 456, 789);`
fn handle_int(e &ui.Event) voidptr {
	num1 := e.get_arg[int](idx: 0) or { return ui.no_result }
	num2 := e.get_arg[int](idx: 1) or { 0 }
	num3 := e.get_arg[int](idx: 2) or { 0 }

	println('handle_int 1: ${num1}') // 123
	println('handle_int 2: ${num2}') // 456
	println('handle_int 3: ${num3}') // 789

	return ui.no_result
}

// JavaScript: webui.handleBool(true, false);
fn handle_bool(e &ui.Event) voidptr {
	status1 := e.get_arg[bool]() or { return ui.no_result }
	status2 := e.get_arg[bool](idx: 1) or { return ui.no_result }

	println('handle_bool 1: ${status1}') // true
	println('handle_bool 2: ${status2}') // false

	return ui.no_result
}

// JavaScript: `const result = await webui.getResponse(number);`
fn get_response(e &ui.Event) int {
	number := e.get_arg[int]() or { return 0 } * 2

	println('get_response: ${number}')

	return number
}

// Create a window.
mut w := ui.new_window()

// Show the window, panic on fail.
w.show(doc)!

w.bind('handleStr', handle_str)
w.bind('handleInt', handle_int)
w.bind('handleBool', handle_bool)
w.bind('getResponse', get_response)

// Wait until all windows get closed.
ui.wait()
