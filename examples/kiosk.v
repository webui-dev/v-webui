import vwebui as ui

mut w := ui.new_window()
w.set_kiosk(true)
w.show('<!DOCTYPE html>
<html>
	<head>
		<title>Kiosk Example</title>
		<style>
			body {
				background: linear-gradient(to left, #36265a, #654da9);
				color: AliceBlue;
				font: 16px sans-serif;
				text-align: center;
				margin-top: 30px;
			}
		</style>
		<!-- Connect this window to the background app -->
		<script src="/webui.js"></script>
	</head>
	<body>
		<h1>WebUI - Kiosk Example</h1>
	</body>
</html>')!
ui.wait()
