# V-WebUI

Use any web browser as GUI, with V in the backend and HTML5 in the frontend, all in a lightweight portable lib.

![ScreenShot](screenshot.png)

## Features

- Fully Independent (*No need for any third-party runtimes*)
- Lightweight (*~900 Kb*) & Small memory footprint
- Fast binary communication protocol between WebUI and the browser (*Instead of JSON*)
- Multi-platform & Multi-Browser
- Using private profile for safety

## Screenshot

This [text editor example](https://github.com/malisipi/vwebui/tree/main/examples/text-editor) is written in V using WebUI as the GUI library.

![ScreenShot](v_example.png)

## Installation

```sh
v install https://github.com/webui-dev/v-webui
```

> **Note**
> On Windows it is recommended to use GCC or Clang to compile a WebUI V program. TCC is currently not working due to missing header files.
> You can use the `-cc` flag to specify a custom compiler. E.g., `v -cc gcc run .`

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
