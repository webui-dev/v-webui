import vwebui as ui

fn my_function_string(e &ui.Event) {
	// JavaScript:
	// webui.call('MyID_One', 'Hello');

	response := e.string()
	println('my_function_string: ${response}') // Hello

	// Need Multiple Arguments?
	//
	// WebUI support only one argument. To get multiple arguments
	// you can send a JSON string from JavaScript then decode it.
}

fn my_function_integer(e &ui.Event) {
	// JavaScript:
	// webui.call('MyID_Two', 123456789);

	response := e.int()
	println('my_function_integer: ${response}') // 123456789
}

fn my_function_boolean(e &ui.Event) {
	// JavaScript:
	// webui.call('MyID_Three', true);

	response := e.bool()
	println('my_function_boolean: ${response}') // true
}

fn my_function_with_response(e &ui.Event) {
	// JavaScript:
	// const result = webui.call('MyID_Four', number);

	number := e.int() * 2
	println('my_function_with_response: ${number}')
	e.@return(number)
}

doc := '<!DOCTYPE html>
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
		<!-- Connect this window to the background app -->
		<script src="/webui.js"></script>
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

// Show the window, panic on fail
w.show(doc) or { panic(err) }

w.bind('MyID_One', my_function_string)
w.bind('MyID_Two', my_function_integer)
w.bind('MyID_Three', my_function_boolean)
w.bind('MyID_Four', my_function_with_response)

// Wait until all windows get closed
ui.wait()
