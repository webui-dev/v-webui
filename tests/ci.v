import os

mut res := os.execute('v -cc clang -stats test .')
if res.exit_code == 0 {
	println(res.output)
	return
}
res = os.execute('v -cc clang -stats -d webui_log test .')
println(res.output)
