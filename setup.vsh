#!/usr/bin/env -S v

import cli
import os

const (
	is_ci = $if ci ? {
		true
	} $else {
		false
	}
	lib_url   = 'https://github.com/webui-dev/webui'
	lib_dir   = os.join_path(@VMODROOT, 'webui')
	build_dir = if is_ci {
		lib_dir + '_tmp'
	} else {
		os.join_path(os.temp_dir(), 'webui')
	}
)

fn clean() {
	// Remove old library files
	$if windows {
		execute('rd /s /q ${build_dir}')
		execute('rd /s /q ${lib_dir}')
	} $else {
		rmdir_all(build_dir) or {}
		rmdir_all(lib_dir) or {}
	}
}

fn which(cmd string) !string {
	$if windows {
		paths := execute('where ${cmd}').output.trim_space().split_into_lines()
		for p in paths {
			if p.contains(cmd) {
				return p
			}
		}
	} $else {
		path := execute('which ${cmd}').output.trim_space()
		if path != '' {
			return path
		}
	}
	return error('Failed finding make command.')
}

fn get() ! {
	clone_cmd := 'git clone --depth 1 ${lib_url}'
	println('Cloning...')
	println(clone_cmd)
	clone_res := execute('${clone_cmd} ${build_dir}')
	if clone_res.exit_code != 0 {
		return error('Failed cloning WebUI. ${clone_res.output}')
	}
}

fn build() ! {
	build_cmd := $if windows { 'mingw32-make' } $else { 'make' }
	println('\nBuilding...')
	cmd := which(build_cmd)!
	mut p := new_process(cmd)
	p.set_work_folder(build_dir)
	p.wait()
	required := 'libwebui-2-static.a'
	if !exists('${build_dir}/dist/${required}') {
		return error('Failed building WebUI. Can\'t find required build output ${required}')
	}
}

fn move() ! {
	// The using `os.mv` steps currently turns out saver than e.g., especially on Windows
	// execute('mv ${lib_dir}/dist/ ./dist/ && mv ${lib_dir}/include/* ./dist/')
	chdir(build_dir)!
	mv('include/webui.h', 'dist/webui.h')!
	mv('include/webui.hpp', 'dist/webui.hpp')!
	mv('dist/', lib_dir)!
}

fn run(cmd cli.Command) ! {
	clean()
	get()!
	build()!
	move()!
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
	execute: run
}
cmd.parse(os.args)
