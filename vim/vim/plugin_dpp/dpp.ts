import {
    type ContextBuilder,
    type ExtOptions,
    type Plugin,
} from "jsr:@shougo/dpp-vim@^5.0.0/types";
import {
    BaseConfig,
    type ConfigReturn,
    type MultipleHook,
} from "jsr:@shougo/dpp-vim@^5.0.0/config";
import type {
    Ext as TomlExt,
    Params as TomlParams,
} from "jsr:@shougo/dpp-ext-toml@^2.0.0";
import type {
    Ext as LazyExt,
    LazyMakeStateResult,
    Params as LazyParams,
} from "jsr:@shougo/dpp-ext-lazy@^2.0.0";
import { Denops } from "jsr:@denops/std@^8.0.0";
import * as os from "node:os";
import * as fs from "jsr:@std/fs@^1.0.0";
import * as path from "jsr:@std/path@^1.0.0";


function mergeFtplugins(
    record: Record<string, string>,
    ftplugins: Record<string, string>,
) {
    for (const filetype of Object.keys(ftplugins)) {
        if (record[filetype]) {
            record[filetype] += `\n${ftplugins[filetype]}`;
        } else {
            record[filetype] = ftplugins[filetype];
        }
    }
}


export class Config extends BaseConfig {
    override async config(args: {
	denops: Denops;
	contextBuilder: ContextBuilder;
	basePath: string;
    }): Promise<ConfigReturn> {
	const protocols = ["git"];
	args.contextBuilder.setGlobal({
	    protocols,
	});

	const [context, options] = await args.contextBuilder.get(args.denops);

	const home_directory = os.homedir();
	const vim_base_directory = os.platform() == "win32" ? "_vim" : ".vim";
	const config_directory = path.join(home_directory, vim_base_directory, "plugin_dpp");

	const is_nvim = await args.denops.call("has", "nvim") === 1;


	const recordPlugins: Record<string, Plugin> = {};
	const ftplugins: Record<string, string> = {};
	const hooksFiles: string[] = [];
	let multipleHooks: MultipleHook[] = [];


	// Load toml plugins

	const tomlFiles = [
	    { path: path.join(config_directory, "dpp_plugin.toml"), lazy: false },
	]

	if (is_nvim) {
	    tomlFiles.push(
		{
		    path: path.join(config_directory, "dpp_plugin_nvim.toml"),
		    lazy: false
		}
	    );
	}

	const [tomlExt, tomlOptions, tomlParams]: [
	    TomlExt | undefined,
	    ExtOptions,
	    TomlParams,
	] = await args.denops.dispatcher.getExt(
	    "toml",
	) as [TomlExt | undefined, ExtOptions, TomlParams];

	const action = tomlExt.actions.load;

	const tomlPromises = tomlFiles.map((tomlFile) =>
	      action.callback({
		  denops: args.denops,
		  context,
		  options,
		  protocols,
		  extOptions: tomlOptions,
		  extParams: tomlParams,
		  actionParams: {
		      path: tomlFile.path,
		      options: {
			  lazy: tomlFile.lazy,
		      },
		  },
	      })
	 );

	 const tomls = await Promise.all(tomlPromises);

	 // Merge toml results
	 for (const toml of tomls) {
	     for (const plugin of toml.plugins ?? []) {
		 recordPlugins[plugin.name] = plugin;
	     }

	     if (toml.ftplugins) {
		 mergeFtplugins(ftplugins, toml.ftplugins);
	     }

	     if (toml.multiple_hooks) {
		 multipleHooks = multipleHooks.concat(toml.multiple_hooks);
	     }

	     if (toml.hooks_file) {
		 hooksFiles.push(toml.hooks_file);
	     }
	 }


	const [lazyExt, lazyOptions, lazyParams]: [
	    LazyExt | undefined,
	    ExtOptions,
	    LazyParams,
	] = await args.denops.dispatcher.getExt(
	    "lazy",
	) as [LazyExt | undefined, ExtOptions, LazyParams];
	let lazyResult: LazyMakeStateResult | undefined = undefined;
	if (lazyExt) {
	    const action = lazyExt.actions.makeState;

	    lazyResult = await action.callback({
		denops: args.denops,
		context,
		options,
		protocols,
		extOptions: lazyOptions,
		extParams: lazyParams,
		actionParams: {
		    plugins: Object.values(recordPlugins),
		},
	    });
	}


	for (const plugin_name in recordPlugins) {
	    const hooks_file_path = path.join(config_directory, plugin_name) + ".vim";
	    if (fs.existsSync(hooks_file_path.replace("~", os.homedir()))) {
		if (Array.isArray(recordPlugins[plugin_name].hooks_file)) {
		    (recordPlugins[plugin_name].hooks_file as string[]).push(hooks_file_path);
		} else if (typeof recordPlugins[plugin_name].hooks_file === "undefined") {
		    recordPlugins[plugin_name].hooks_file = hooks_file_path;
		} else {
		    recordPlugins[plugin_name].hooks_file = [String(recordPlugins[plugin_name].hooks_file), hooks_file_path];
		}
	    }
	}


	return {
	    checkFiles: [path.join(config_directory, "dpp.ts")].concat(tomlFiles.map(file => file.path)).concat(hooksFiles),
	    ftplugins,
	    hooksFiles,
	    multipleHooks,
	    plugins: lazyResult?.plugins ?? [],
	    stateLines: lazyResult?.stateLines ?? [],
	};


	// const check_files = new Map([
	//     [ "config", path.join(config_directory, "dpp.ts") ],
	//     [ "toml", path.join(config_directory, "dpp_plugin.toml") ]
	// ]);
	// 
	// if (is_nvim) {
	//     check_files.set("toml_nvim", path.join(config_directory, "dpp_plugin_nvim.toml"));
	// }
	// 
	// // Load toml plugins
	// const tomls: Toml[] = [];
	// 
	// const load_toml = async (target: string): Promise<void> => {
	//     const toml = await args.dpp.extAction(
	// 	args.denops,
	// 	context,
	// 	options,
	// 	"toml",
	// 	"load",
	// 	{
	// 	    path: check_files.get(target),
	// 	    options: {
	// 		lazy: false,
	// 	    },
	// 	},
	//     ) as Toml | undefined;
	// 
	//     if (toml) {
	// 	tomls.push(toml);
	//     }
	// }
	// 
	// await load_toml("toml");
	// if (is_nvim) {
	//     await load_toml("toml_nvim");
	// }
	// 
	// // Merge toml results
	// const record_plugins: Record<string, Plugin> = {};
	// const ftplugins: Record<string, string> = {};
	// const hooks_files: string[] = [];
	// 
	// for (const toml of tomls) {
	//     for (const plugin of toml.plugins) {
	// 	record_plugins[plugin.name] = plugin;
	//     }
	// 
	//     if (toml.ftplugins) {
	// 	for (const filetype of Object.keys(toml.ftplugins)) {
	// 	    if (ftplugins[filetype]) {
	// 		ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
	// 	    } else {
	// 		ftplugins[filetype] = toml.ftplugins[filetype];
	// 	    }
	// 	}
	//     }
	// 
	//     if (toml.hooks_file) {
	// 	hooks_files.push(toml.hooks_file);
	//     }
	// }
	// 
	// for (const plugin_name in record_plugins) {
	//     const hooks_file_path = path.join(config_directory, plugin_name) + ".vim";
	//     if (fs.existsSync(hooks_file_path.replace("~", os.homeDir() ?? ""))) {
	// 	if (Array.isArray(record_plugins[plugin_name].hooks_file)) {
	// 	    (record_plugins[plugin_name].hooks_file as string[]).push(hooks_file_path);
	// 	} else if (typeof record_plugins[plugin_name].hooks_file === "undefined") {
	// 	    record_plugins[plugin_name].hooks_file = hooks_file_path;
	// 	} else {
	// 	    record_plugins[plugin_name].hooks_file = [String(record_plugins[plugin_name].hooks_file), hooks_file_path];
	// 	}
	//     }
	// }
	// 
	// return {
	//     checkFiles: [ ...check_files.values() ].concat(hooks_files),
	//     plugins: Object.values(record_plugins),
	//     stateLines: []
	// };
    }
}
