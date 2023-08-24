import vwebui as ui

fn my_function_count(e &ui.Event) ui.Response {
	count := e.window.script('return count;', 0, 48)
	e.window.script('SetCount(${count.int() + 1});', 0, 0)
	return 0
}

fn my_function_exit(e &ui.Event) ui.Response { // Close all opened windows
	ui.exit()
	return 0
}

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
  </head>
  <body>
    <h1>WebUI - Call JavaScript from V</h1>
    <br>
    <button id="MyButton1">Count <span id="count">0<span></button>
    <br>
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

mut w := ui.new_window() // Create a window

// Bind HTML elements with functions
w.bind('MyButton1', my_function_count)
w.bind('MyButton2', my_function_exit)

// Show the window
if !w.show(doc) { // Run the window
	panic('The browser(s) was failed') // If not, print a error info
}

// Wait until all windows get closed
ui.wait()
