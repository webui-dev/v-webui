import vwebui as webui

fn my_function_string(e &webui.Event) webui.Response {
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

fn my_function_integer(e &webui.Event) webui.Response {
	// JavaScript:
	// webui.call('MyID_Two', 123456789);

	response := e.data.int
	println('my_function_integer: ${response}') // 123456789
	return 0
}

fn my_function_boolean(e &webui.Event) webui.Response {
	// JavaScript:
	// webui.call('MyID_Three', true);

	response := e.data.bool
	println('my_function_boolean: ${response}') // true
	return 0
}

fn my_function_with_response(e &webui.Event) webui.Response {
	// JavaScript:
	// const result = webui.call('MyID_Four', number);

	number := e.data.int * 2
	println('my_function_with_response: ${number}')
	return number
}

mut my_window := webui.new_window() // Create a window

my_html := '
<html>
  <head>
    <title>Call V from JavaScript Example</title>
    <style>
      body {
        color: white;
        background: #0F2027;
        text-align: center;
        font-size: 16px;
        font-family: sans-serif;
      }
    </style>
  </head>
  <body>
    <h2>WebUI - Call V from JavaScript Example</h2>
    <p>Call V function with argument (<em>See the logs in your terminal</em>)</p>
    <br>
    <button onclick="webui.call(\'MyID_One\', \'Hello\');">Call my_function_string()</button>
    <br>
    <br>
    <button onclick="webui.call(\'MyID_Two\', 123456789);">Call my_function_integer()</button>
    <br>
    <br>
    <button onclick="webui.call(\'MyID_Three\', true);">Call my_function_boolean()</button>
    <br>
    <br>
    <p>Call V function and wait for the response</p>
    <br>
    <button onclick="MyJS();">Call my_function_with_response()</button>
    <br>
    <br>
    <input type="text" id="MyInputID" value="2">
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

if !my_window.show(my_html) { // Run the window
	panic('The browser(s) was failed') // If not, print a error info
}

my_window.bind('MyID_One', my_function_string)
	.bind('MyID_Two', my_function_integer)
	.bind('MyID_Three', my_function_boolean)
	.bind('MyID_Four', my_function_with_response)

// Wait until all windows get closed
webui.wait()
