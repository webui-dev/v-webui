#!/usr/bin/env -S v

import cli
import os
import v.pref
import net.http

// Latest tag that should is tested with the wrapper.
// Other versions might include breaking changes.
const webui_version = '2.4.2'
const platform = pref.get_host_os()
const arch = pref.get_host_arch()
const base_url = 'https://github.com/webui-dev/webui/releases'
const archives = {
	'Linux':   {
		'amd64':   'webui-linux-gcc-x64.zip'
		'aarch64': 'webui-linux-gcc-arm64.zip'
		'arm64':   'webui-linux-gcc-arm64.zip'
		'arm32':   'webui-linux-gcc-arm.zip'
	}
	'MacOS':   {
		'amd64': 'webui-macos-clang-x64.zip'
		'arm64': 'webui-macos-clang-arm64.zip'
	}
	'Windows': {
		'amd64': 'webui-windows-gcc-x64.zip'
	}
}

fn run(cmd cli.Command) ! {
	out_dir := cmd.flags.get_string('output')!
	nightly := cmd.flags.get_bool('nightly')!
	latest := cmd.flags.get_bool('nightly')!

	// Remove old library files.
	// TODO: remove WebUI files selectively instead of the entire dir to avoid deleting potentially added user files.
	$if windows {
		// During tests, `rmdir_all` on Windows could run into permission errors.
		execute('rd /s /q ${out_dir}')
	} $else {
		rmdir_all(out_dir) or {}
	}

	archive := archives[platform.str()] or {
		return error('The setup script currently does not support `${platform}`.')
	}[arch.str()] or {
		return error('The setup script currently does not support `${arch}` architectures on `${platform}`.')
	}

	version, version_url := match true {
		latest { 'lastest', 'latest/download' }
		nightly { 'nightly', 'download/nightly' }
		else { webui_version, 'download/${webui_version}' }
	}
	println('Downloading WebUI@${version}...')
	url := '${base_url}/${version_url}/${archive}'
	http.download_file(url, archive) or {
		return error('Failed downloading archive `${archive}` from `${url}`. ${err}')
	}

	println('Extracting...')
	$if windows {
		unzip_res := execute('powershell -command Expand-Archive -LiteralPath ${archive}')
		if unzip_res.exit_code != 0 {
			return error('Failed extracting archive `${archive}`. ${unzip_res.output}')
		}
		dir := archive.all_before('.zip')
		mv(join_path(dir, dir), out_dir)!
		rmdir(dir)!
	} $else {
		if system('unzip -o ${archive}') != 0 {
			return error('Failed to extract archive `${archive}`')
		}
		mv(archive.all_before('.zip'), out_dir)!
	}
	rm(archive)!

	println('Done.')
}

mut cmd := cli.Command{
	name: 'setup.vsh'
	posix_mode: true
	required_args: 0
	pre_execute: fn (cmd cli.Command) ! {
		if cmd.args.len > cmd.required_args {
			eprintln('Unknown commands ${cmd.args}.\n')
			cmd.execute_help()
			exit(0)
		}
	}
	flags: [
		cli.Flag{
			flag: .string
			name: 'output'
			abbrev: 'o'
			description: 'Specify the output path for the download WebUI platfrom release.'
			global: true
			default_value: [join_path(@VMODROOT, 'webui')]
		},
		// Download other versions, might include breaking changes.
		cli.Flag{
			flag: .bool
			name: 'nightly'
			description: 'Download the nightly version instead of the latest stable version.'
			global: true
		},
		cli.Flag{
			flag: .bool
			name: 'latest'
			description: 'Download the latest latest stable version.'
			global: true
		},
	]
	execute: run
}
cmd.parse(os.args)
