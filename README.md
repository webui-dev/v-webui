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
  <a href="https://github.com/webui-dev/v-webui">
    <img
      alt="Repo Size"
      src="https://img.shields.io/github/repo-size/webui-dev/v-webui?style=for-the-badge&label=SIZE&logo=git&logoColor=C0CAF5&labelColor=414868&color=8c73cc"
    >
  </a>
  <a href="https://github.com/webui-dev/v-webui/blob/main/LICENSE">
    <img
      alt="License"
      src="https://img.shields.io/github/license/webui-dev/v-webui?style=for-the-badge&amp&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868"
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
        background-color: SlateGray;
        color: GhostWhite;
        text-align: center;
      }
    </style>
  </head>
  <body>
    <button onclick="webui.call(\'my_v_func\')">Call V!</button>
    <h1>Thanks for using WebUI!</h1>
  </body>
</html>'

fn my_v_func(e &ui.Event) ui.Response {
	println('Hello From V!')
	return 0
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

> Licensed under the MIT License.
