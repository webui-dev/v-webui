<div align="center">

# V-WebUI

#### [Features](#features) · [Installation](#installation) · [Usage](#usage) · [Documentation](#documentation) · [WebUI](https://github.com/webui-dev/webui)

[build-status]: https://img.shields.io/github/actions/workflow/status/webui-dev/v-webui/ci.yml?branch=main&style=for-the-badge&logo=V&labelColor=414868&logoColor=C0CAF5
[last-commit]: https://img.shields.io/github/last-commit/webui-dev/v-webui?style=for-the-badge&logo=github&logoColor=C0CAF5&labelColor=414868
[release-version]: https://img.shields.io/github/v/release/webui-dev/v-webui?style=for-the-badge&logo=webtrees&logoColor=C0CAF5&labelColor=414868&color=7664C6
[license]: https://img.shields.io/github/license/webui-dev/v-webui?style=for-the-badge&logo=opensourcehardware&label=License&logoColor=C0CAF5&labelColor=414868&color=8c73cc

[![][build-status]](https://github.com/webui-dev/v-webui/actions?query=branch%3Amain)
[![][last-commit]](https://github.com/webui-dev/v-webui/pulse)
[![][release-version]](https://github.com/webui-dev/v-webui/releases/latest)
[![][license]](https://github.com/webui-dev/v-webui/blob/main/LICENSE)

> WebUI is not a web-server solution or a framework, but it allows you to use any web browser as a GUI, with your preferred language in the backend and HTML5 in the frontend. All in a lightweight portable lib.

![Screenshot](https://github.com/webui-dev/webui/assets/34311583/57992ef1-4f7f-4d60-8045-7b07df4088c6)

</div>

## Features

- Parent library written in pure C
- Fully Independent (_No need for any third-party runtimes_)
- Lightweight ~200 Kb & Small memory footprint
- Fast binary communication protocol between WebUI and the browser (_Instead of JSON_)
- One header file
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
    <button onclick="webui.my_v_func()">Call V!</button>
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

- To use WebUI's debug build in your V-WebUI application, add the `-d webui_log` flag. E.g.:

  ```sh
  v -d webui_log run examples/call_v_from_js.v
  ```

- Run tests locally:

  ```sh
  VJOBS=1 v -stats test tests/
  ```

## Supported Web Browsers

| Browser         | Windows         | macOS         | Linux           |
| --------------- | --------------- | ------------- | --------------- |
| Mozilla Firefox | ✔️              | ✔️            | ✔️              |
| Google Chrome   | ✔️              | ✔️            | ✔️              |
| Microsoft Edge  | ✔️              | ✔️            | ✔️              |
| Chromium        | ✔️              | ✔️            | ✔️              |
| Yandex          | ✔️              | ✔️            | ✔️              |
| Brave           | ✔️              | ✔️            | ✔️              |
| Vivaldi         | ✔️              | ✔️            | ✔️              |
| Epic            | ✔️              | ✔️            | _not available_ |
| Apple Safari    | _not available_ | _coming soon_ | _not available_ |
| Opera           | _coming soon_   | _coming soon_ | _coming soon_   |

### License

> Licensed under the MIT License.
