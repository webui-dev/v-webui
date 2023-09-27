#!/usr/bin/env -S v

import cli
import os
import v.pref
import net.http

const (
	platform = pref.get_host_os()
	arch     = pref.get_host_arch()
	base_url = 'https://github.com/webui-dev/webui/releases/'
	archives = {
		'Linux':   {
			'amd64': 'webui-linux-gcc-x64.tar.gz'
		}
		'MacOS':   {
			'amd64': 'webui-macos-clang-x64.tar.gz'
			'arm64': 'webui-macos-clang-arm64.tar.gz'
		}
		'Windows': {
			'amd64': 'webui-windows-gcc-x64.zip'
		}
	}
)

fn run(cmd cli.Command) ! {
	out_dir := cmd.flags.get_string('output')!
	nightly := cmd.flags.get_bool('nightly')!

	// Remove old library files.
	// TODO: remove that wit certainty are WebUI files instead of full dir.
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

	println('Downloading...')
	url := base_url + if nightly { 'download/nightly/' } else { 'latest/download/' }
	http.download_file(url + archive, archive) or {
		return error('Failed downloading archive `${archive}`. ${err}')
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
		unzip_res := execute('tar -xvzf ${archive}')
		if unzip_res.exit_code != 0 {
			return error('Failed extracting archive `${archive}`. ${unzip_res.output}')
		}
		mv(archive.all_before('.tar'), out_dir)!
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
		cli.Flag{
			flag: .bool
			name: 'nightly'
			description: 'Download the nightly version instead of the latest stable version.'
			global: true
			default_value: ['true'] // Remove after WebUI v2.4.0 was released
		},
	]
	execute: run
}
cmd.parse(os.args)
