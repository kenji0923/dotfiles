import {
    BaseConfig,
    ContextBuilder,
    Dpp,
    Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.9/types.ts";
import { Denops } from "https://deno.land/x/dpp_vim@v0.0.9/deps.ts";
import os from "https://deno.land/x/dos@v0.11.0/mod.ts";
import * as path from "https://deno.land/std@0.215.0/path/mod.ts";
import * as fs from "https://deno.land/std@0.215.0/fs/mod.ts";

type Toml = {
    hooks_file?: string;
    ftplugins?: Record<string, string>;
    plugins: Plugin[];
};

export class Config extends BaseConfig {
    override async config(args: {
	denops: Denops;
	contextBuilder: ContextBuilder;
	basePath: string;
	dpp: Dpp;
    }): Promise<{
	checkFiles: string[];
	plugins: Plugin[];
	stateLines: string[];
    }> {
	args.contextBuilder.setGlobal({
	    protocols: ['git'],
	});

	const [context, options] = await args.contextBuilder.get(args.denops);

	const home_directory = os.homeDir();
	const vim_base_directory = os.platform() == "windows" ? "_vim" : ".vim";
	const config_directory = path.join(home_directory, vim_base_directory, "plugin_dpp");

	const check_files = new Map([
	    [ "config", path.join(config_directory, "dpp.ts") ],
	    [ "toml", path.join(config_directory, "dpp_plugin.toml") ]
	]);

	// Load toml plugins
	const tomls: Toml[] = [];

	const toml = await args.dpp.extAction(
	    args.denops,
	    context,
	    options,
	    "toml",
	    "load",
	    {
		path: check_files.get("toml"),
		options: {
		    lazy: false,
		},
	    },
	) as Toml | undefined;

	if (toml) {
	    tomls.push(toml);
	}

	// Merge toml results
	const record_plugins: Record<string, Plugin> = {};
	const ftplugins: Record<string, string> = {};
	const hooks_files: string[] = [];

	for (const toml of tomls) {
	    for (const plugin of toml.plugins) {
		record_plugins[plugin.name] = plugin;
	    }

	    if (toml.ftplugins) {
		for (const filetype of Object.keys(toml.ftplugins)) {
		    if (ftplugins[filetype]) {
			ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
		    } else {
			ftplugins[filetype] = toml.ftplugins[filetype];
		    }
		}
	    }

	    if (toml.hooks_file) {
		hooks_files.push(toml.hooks_file);
	    }
	}

	for (const plugin_name in record_plugins) {
	    const hooks_file_path = path.join(config_directory, plugin_name) + ".vim";
	    if (fs.existsSync(hooks_file_path.replace("~", os.homeDir()))) {
		if (Array.isArray(record_plugins[plugin_name].hooks_file)) {
		    Array(record_plugins[plugin_name].hooks_file).push(hooks_file_path);
		} else if (typeof record_plugins[plugin_name].hooks_file === "undefined") {
		    record_plugins[plugin_name].hooks_file = hooks_file_path;
		} else {
		    record_plugins[plugin_name].hooks_file = [String(record_plugins[plugin_name].hooks_file), hooks_file_path];
		}
	    }
	}

	return {
	    checkFiles: [ ...check_files.values() ].concat(hooks_files),
	    plugins: Object.values(record_plugins),
	    stateLines: []
	};
    }
}
