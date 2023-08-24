import vwebui as ui

fn my_function_string(e &ui.Event) ui.Response {
	// JavaScript:
	// webui.call('MyID_One', 'Hello');

	response := e.data.string
	println('my_function_string: ${response}') // Hello

	// Need Multiple Arguments?
	//
	// WebUI support only one argument. To get multiple arguments
	// you can send a JSON string from JavaScript then decode it.
	return 0
}

fn my_function_integer(e &ui.Event) ui.Response {
	// JavaScript:
	// webui.call('MyID_Two', 123456789);

	response := e.data.int
	println('my_function_integer: ${response}') // 123456789
	return 0
}

fn my_function_boolean(e &ui.Event) ui.Response {
	// JavaScript:
	// webui.call('MyID_Three', true);

	response := e.data.bool
	println('my_function_boolean: ${response}') // true
	return 0
}

fn my_function_with_response(e &ui.Event) ui.Response {
	// JavaScript:
	// const result = webui.call('MyID_Four', number);

	number := e.data.int * 2
	println('my_function_with_response: ${number}')
	return number
}

const doc = '<!DOCTYPE html>
<html>
	<head>
		<title>Call V from JavaScript Example</title>
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
		<button onclick="webui.call(\'MyID_One\', \'Hello\');">Call my_function_string()</button>
		<br>
		<button onclick="webui.call(\'MyID_Two\', 123456789);">Call my_function_integer()</button>
		<br>
		<button onclick="webui.call(\'MyID_Three\', true);">Call my_function_boolean()</button>
		<br>
		<p>Call a V function that returns a response</p>
		<button onclick="MyJS();">Call my_function_with_response()</button>
		<div>Double: <input type="text" id="MyInputID" value="2"></div>
		<script>
			function MyJS() {
				const MyInput = document.getElementById("MyInputID");
				const number = MyInput.value;
				webui.call("MyID_Four", number).then((response) => {
						MyInput.value = response;
				});
			}
		</script>
	</body>
</html>'

mut w := ui.new_window() // Create a window

if !w.show(doc) { // Run the window
	panic('The browser(s) was failed') // If not, print a error info
}

w.bind('MyID_One', my_function_string)
	.bind('MyID_Two', my_function_integer)
	.bind('MyID_Three', my_function_boolean)
	.bind('MyID_Four', my_function_with_response)

// Wait until all windows get closed
ui.wait()
