module utils

import time

fn gen_html(test_name string, script string) string {
	return '<html style="background: #654da9; color: #eee">
<head>
	<script src="webui.js"></script>
</head>
<samp>${test_name}</samp>
<script>${script}</script>
</html>'
}

fn timeout(seconds usize, cb fn () bool) bool {
	for _ in 0 .. seconds * 10 {
		if cb() {
			return true
		}
		time.sleep(100 * time.millisecond)
	}
	return false
}
