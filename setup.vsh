#!/usr/bin/env -S v

import cli
import os
import v.pref
import net.http
import json
import compress.szip
import term { colorize }
import arrays
import semver

// https://api.github.com/repos/webui-dev/webui/releases
struct Release {
	tag_name   string
	prerelease bool
}

struct Releases {
	c []Release
	v []Release
}

const webui_release_base_url = 'https://github.com/webui-dev/webui/releases'
const platform = pref.get_host_os()
const arch = pref.get_host_arch()
const archives = {
	pref.OS.linux: {
		pref.Arch.amd64: 'webui-linux-gcc-x64.zip'
		.arm64:          'webui-linux-gcc-arm64.zip'
		.arm32:          'webui-linux-gcc-arm.zip'
	}
	.macos:        {
		pref.Arch.amd64: 'webui-macos-clang-x64.zip'
		.arm64:          'webui-macos-clang-arm64.zip'
	}
	.windows:      {
		pref.Arch.amd64: 'webui-windows-gcc-x64.zip'
	}
}

fn get_webui_releases() !Releases {
	mut request := http.Request{}
	token := os.getenv('WEBUI_GH_TOKEN')
	if token != '' {
		request.header.add(.authorization, 'Bearer ${token}')
	}
	request.url = 'https://api.github.com/repos/webui-dev/webui/releases'
	c_repo_resp := request.do()!
	if c_repo_resp.status_code != 200 {
		return error('Failed get success status when fetching WebUI releases: ${c_repo_resp}')
	}
	request.url = 'https://api.github.com/repos/webui-dev/v-webui/releases'
	v_repo_resp := request.do()!
	if v_repo_resp.status_code != 200 {
		return error('Failed get success status when fetching V-WebUI releases: ${v_repo_resp}')
	}
	return Releases{json.decode([]Release, c_repo_resp.body)!, json.decode([]Release,
		v_repo_resp.body)!}
}

fn (releases Releases) find_matching_parent_tag(tag string) ?string {
	last_v_tag := releases.v[0].tag_name.trim_string_left('v')
	for release in releases.c {
		if release.tag_name.trim_string_left('v') == last_v_tag {
			return release.tag_name
		}
	}
	return none
}

fn run(cmd cli.Command) ! {
	out_dir := cmd.flags.get_string('output')!

	releases := get_webui_releases() or { return error('Failed to fetch releases: ${err}') }
	$if debug && verbose ? {
		dump(releases)
	}

	archive := archives[platform] or {
		return error('The setup script currently does not support `${platform}`.')
	}[arch] or {
		return error('The setup script currently does not support `${arch}` architectures on `${platform}`.')
	}
	$if debug {
		dump(archive)
	}

	if os.exists(out_dir) {
		input := os.input('WebUI output directory `${out_dir}` already exists.
${colorize(term.blue,
			'::')} Do you want to replace it? [Y/n] ${colorize(term.blue, '❯')} ')
		if input.to_lower() != 'y' {
			return
		}
		$if windows {
			// During tests on Windows, `rmdir_all` ocassionally run into permission errors.
			execute('rd /s /q ${out_dir}')
		} $else {
			rmdir_all(out_dir) or {}
		}
	}

	version_arg := cmd.args[0] or { 'latest' }
	version := match version_arg {
		'nightly' {
			releases.c[0].tag_name
		}
		'latest' {
			// vfmt off
			arrays.find_first(releases.c, fn (it Release) bool {
				return !it.prerelease
			}) or { return error('Failed to find WebUI release') }.tag_name
			// vfmt on
		}
		else {
			releases.find_matching_parent_tag(version_arg) or {
				return error('Failed to find the matching WebUI C release.')
			}
		}
	}
	$if debug {
		dump(version)
	}

	tmp_dir := os.join_path(os.temp_dir(), 'webui_${version}')
	os.mkdir(tmp_dir) or {}
	defer {
		rmdir_all(tmp_dir) or {}
	}

	println('Downloading WebUI@${version}...')
	url := '${webui_release_base_url}/download/${version}/${archive}'
	archive_download_dest := os.join_path(tmp_dir, archive)
	$if debug {
		dump(url)
		dump(archive_download_dest)
	}
	http.download_file(url, archive_download_dest) or {
		return error('Failed downloading archive `${archive}` from `${url}`. ${err}')
	}

	println('Extracting...')
	szip.extract_zip_to_dir(archive_download_dest, tmp_dir)!
	if version != 'nightly' {
		if semver.from(version)! < semver.from('2.4.1')! {
			os.rm(archive_download_dest) or {}
			mv(tmp_dir, out_dir)!
		} else {
			mv(archive_download_dest.all_before('.zip'), out_dir)!
		}
	} else {
		mv(archive_download_dest.all_before('.zip'), out_dir)!
	}

	println('Done.')
}

mut cmd := cli.Command{
	name: 'setup.vsh'
	usage: '<version>'
	posix_mode: true
	pre_execute: fn (cmd cli.Command) ! {
		if cmd.args.len > 1 {
			eprintln('Too many arguments: <${cmd.args}>.\n')
			cmd.execute_help()
			exit(0)
		}
	}
	defaults: struct {
		help: cli.CommandFlag{false, true}
		man: false
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
	]
	execute: run
}
cmd.parse(os.args)
