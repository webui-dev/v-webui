# V-WebUI

> Use any web browser as GUI, with V in the backend and HTML5 in the frontend, all in a lightweight portable lib.

![Screenshot](https://github.com/webui-dev/webui/assets/34311583/57992ef1-4f7f-4d60-8045-7b07df4088c6)

## Features

- Fully Independent (*No need for any third-party runtimes*)
- Lightweight (*~900 Kb*) & Small memory footprint
- Fast binary communication protocol between WebUI and the browser (*Instead of JSON*)
- Multi-platform & Multi-Browser
- Using private profile for safety

## Installation

```sh
v install https://github.com/webui-dev/v-webui
```

## Usage

After the installation, prepare the WebUI library for usage.

```sh
# Linux / macOs
~/.vmodules/vwebui/setup.vsh

# Windows PowerShell
v run $HOME/.vmodules/vwebui/setup.vsh
```

> **Note**
> On Windows it is recommended to use GCC or Clang to compile a WebUI V program. TCC is currently not working due to missing header files.
> You can use the `-cc` flag to specify a custom compiler. E.g.:
>
> ```
> v -cc gcc run .
> ```

### Example

```v
import vwebui as ui

const html = '<!DOCTYPE html>
<html lang="en">
  <head>
    <style>
      body {
        background: linear-gradient(to left, #36265a, #654da9);
        color: AliceBlue;
        font: 16px sans-serif;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <h1>Thanks for using WebUI!</h1>
    <button onclick="webui.call(\'my_v_func\')">Call V!</button>
  </body>
</html>'

fn my_v_func(e &ui.Event) {
	println('Hello From V!')
}

w := ui.new_window()
w.bind('my_v_func', my_v_func)
w.show(html)
ui.wait()
```

Find more examples in the [`examples/`](https://github.com/webui-dev/v-webui/tree/main/examples) directory.

## Documentation

- [Online Documentation - V](https://webui.me/docs/2.4.0/#/v_api)

## Supported Web Browsers

| Browser | Windows | macOS | Linux |
| ------ | ------ | ------ | ------ |
| Mozilla Firefox | ✔️ | ✔️ | ✔️ |
| Google Chrome | ✔️ | ✔️ | ✔️ |
| Microsoft Edge | ✔️ | ✔️ | ✔️ |
| Chromium | ✔️ | ✔️ | ✔️ |
| Yandex | ✔️ | ✔️ | ✔️ |
| Brave | ✔️ | ✔️ | ✔️ |
| Vivaldi | ✔️ | ✔️ | ✔️ |
| Epic | ✔️ | ✔️ | *not available* |
| Apple Safari | *not available* | *coming soon* | *not available* |
| Opera | *coming soon* | *coming soon* | *coming soon* |

### License

> Licensed under MIT License.

### Original Library

> This is just a wrapper written in/for V. Thanks to [WebUI](https://github.com/webui-dev/webui)
