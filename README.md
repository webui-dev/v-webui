<div align="center">

# V-WebUI

<h4 align="center">
  <a href="#features">Features</a>
  ·
  <a href="#installation">Installation</a>
  ·
  <a href="#usage">Usage</a>
  ·
  <a href="#documentation">Documentation</a>
  ·
  <a href="https://github.com/webui-dev/webui">WebUI</a>
</h4>

<div>
  <a href="https://github.com/webui-dev/v-webui/actions?query=branch%3Amain">
    <img
      alt="Build Status"
      src="https://img.shields.io/github/actions/workflow/status/webui-dev/v-webui/ci.yml?branch=main&style=for-the-badge&logo=V&labelColor=414868&logoColor=C0CAF5"
    >
  </a>
  <a href="https://github.com/webui-dev/v-webui/pulse">
    <img
      alt="Last Commit"
      src="https://img.shields.io/github/last-commit/webui-dev/v-webui?style=for-the-badge&logo=github&logoColor=C0CAF5&labelColor=414868"
    />
  </a>
  <a href="https://github.com/webui-dev/v-webui/releases/latest">
    <img
      alt="V-WebUI Release Version"
      src="https://img.shields.io/github/v/release/webui-dev/v-webui?style=for-the-badge&logo=webtrees&logoColor=C0CAF5&labelColor=414868&color=7664C6"
    >
  </a>
  <a href="https://github.com/webui-dev/v-webui/blob/main/LICENSE">
    <img
      alt="License"
      src="https://img.shields.io/github/license/webui-dev/v-webui?style=for-the-badge&amp&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc"
    >
  </a>
</div>

<br>

![Screenshot](https://github.com/webui-dev/webui/assets/34311583/57992ef1-4f7f-4d60-8045-7b07df4088c6)

> WebUI is not a web-server solution or a framework, but it allows you to use any web browser as a GUI, with your preferred language in the backend and HTML5 in the frontend. All in a lightweight portable lib.

</div>

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
v run %USERPROFILE%/.vmodules/vwebui/setup.vsh
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
    <script src="webui.js"></script>
  </head>
  <body>
    <h1>Thanks for using WebUI!</h1>
    <button onclick="webui.call(\'my_v_func\')">Call V!</button>
  </body>
</html>'

fn my_v_func(e &ui.Event) voidptr {
	println('Hello From V!')
	return ui.no_result
}

w := ui.new_window()
w.bind('my_v_func', my_v_func)
w.show(html)!
ui.wait()
```

Find more examples in the [`examples/`](https://github.com/webui-dev/v-webui/tree/main/examples) directory.

## Documentation

- [Online Documentation](https://webui.me/docs/#/v) (WIP)

> **Note**
> Until our Online Documentation is finished, you can referrer to [`src/lib.v`](https://github.com/webui-dev/v-webui/tree/main/src/lib.v) or use V's builtin `v doc -comments vwebui.src` for the latest overview of exported and commented functions.

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

> Licensed under the MIT License.
