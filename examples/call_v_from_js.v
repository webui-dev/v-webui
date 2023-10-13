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
		<button onclick="webui.call(\'MyID_One\', \'Hello\', \'World\');">Call my_function_string()</button>
		<br>
		<button onclick="webui.call(\'MyID_Two\', 123, 456, 789);">Call my_function_integer()</button>
		<br>
		<button onclick="webui.call(\'MyID_Three\', true, false);">Call my_function_boolean()</button>
		<br>
		<p>Call a V function that returns a response</p>
		<button onclick="MyJS();">Call my_function_with_response()</button>
		<div>Double: <input type="text" id="MyInputID" value="2"></div>
		<script>
			async function MyJS() {
				const MyInput = document.getElementById("MyInputID");
				const number = MyInput.value;
				const result = await webui.call("MyID_Four", number);
				MyInput.value = result;
			}
		</script>
	</body>
</html>'

// JavaScript:
// webui.call('MyID_One', 'Hello');
fn my_function_string(e &ui.Event) voidptr {
	str1 := e.get_arg[string]() or { return ui.no_result }
	str2 := e.get_arg[string](idx: 1) or { '' }

	println('my_function_string 1: ${str1}') // Hello
	println('my_function_string 2: ${str2}') // World

	return ui.no_result
}

// JavaScript:
// webui.call('MyID_Two', 123456789);
fn my_function_integer(e &ui.Event) voidptr {
	num1 := e.get_arg[int](idx: 0) or { return ui.no_result }
	num2 := e.get_arg[int](idx: 1) or { 0 }
	num3 := e.get_arg[int](idx: 2) or { 0 }

	println('my_function_integer 1: ${num1}') // 123
	println('my_function_integer 2: ${num2}') // 456
	println('my_function_integer 3: ${num3}') // 789

	return ui.no_result
}

// JavaScript:
// webui.call('MyID_Three', true);
fn my_function_boolean(e &ui.Event) voidptr {
	status1 := e.get_arg[bool]() or { return ui.no_result }
	status2 := e.get_arg[bool](idx: 1) or { return ui.no_result }

	println('my_function_boolean 1: ${status1}') // true
	println('my_function_boolean 2: ${status2}') // false

	return ui.no_result
}

// JavaScript:
// const result = webui.call('MyID_Four', number);
fn my_function_with_response(e &ui.Event) int {
	number := e.get_arg[int]() or { return 0 } * 2

	println('my_function_with_response: ${number}')

	return number
}

// Create a window.
mut w := ui.new_window()

// Show the window, panic on fail.
w.show(doc)!

w.bind('MyID_One', my_function_string)
w.bind('MyID_Two', my_function_integer)
w.bind('MyID_Three', my_function_boolean)
w.bind('MyID_Four', my_function_with_response)

// Wait until all windows get closed.
ui.wait()
