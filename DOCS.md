# WebUI v2.2.0 V APIs

* [Download and Install](#download-and-install)
* Examples
* Window
    * New Window
    * Show Window
    * Window status
* Binding & Events
    * Bind
    * Events
* Application
    * Wait
    * Exit
    * Close
    * Startup Timeput
    * Multi Access

## Download and Install

Install the VWebUI package from VPM (~ 800 Kb).

```sh
v install malisipi.mui
```

To see the VWebUI source code, please visit [VWebUI](https://github.com/malisipi/vwebui) in our GitHub repository.

## Examples

A minimal V example

```v
import malisipi.vwebui as webui

mut my_window := webui.new_window()
my_window.show("<html>Hello</html>")
webui.wait()
```

Please visit [V Examples](https://github.com/malisipi/vwebui/tree/main/examples) in our GitHub repository for more complete examples.