import * as vscode from 'vscode';
import * as tt from './tt';
import * as fs from 'fs';
import * as _ from 'lodash';
import * as semver from 'semver';
import * as utils from './utils';

const annotationsPaths = [
	__dirname + "/Library",
	__dirname + "/Rocks"
];
const emmyrc = {
	"runtime": {
		"version": "LuaJIT"
	},
	"workspace": {
		"library": annotationsPaths
	}
};
const emmyrcFile = '.emmyrc.json';
const globalEmmyrcKey = 'emmylua.misc.globalConfigPath';
const globalEmmyrcPath = __dirname + `/${emmyrcFile}`;
const globalConfigEmmyluaVersion = '0.9.19';

async function initGlobalEmmyrc() {
	const emmyLua = vscode.extensions.getExtension('tangzx.emmylua');
	const emmyLuaVersion = emmyLua?.packageJSON.version;
	if (!semver.gte(emmyLuaVersion, globalConfigEmmyluaVersion)) {
		vscode.window.showWarningMessage(`Unable to set up Tarantool extension globally due to the old version of the EmmyLua extension: current version is ${emmyLuaVersion}, required version is ${globalConfigEmmyluaVersion}. Consider updating EmmyLua using marketplace or run a 'Tarantool: Initialize VS Code extension...' command having your Tarantool project opened`);
		return;
	}

	const config = vscode.workspace.getConfiguration(undefined, null);
	const configuredGlobalEmmyrcPath = config.get(globalEmmyrcKey);

	let existingEmmyrc = {};
	try {
		const f = fs.readFileSync(globalEmmyrcPath, 'utf8');
		existingEmmyrc = JSON.parse(f);
	} catch {
		existingEmmyrc = {};
	}
	const upToDate = _.isMatch(existingEmmyrc, emmyrc);
	if (!upToDate) {
		fs.writeFileSync(globalEmmyrcPath, JSON.stringify(emmyrc, undefined, 2));
	}

	const desiredGlobalEmmyrcPath = globalEmmyrcPath;
	if (configuredGlobalEmmyrcPath !== desiredGlobalEmmyrcPath) {
		try {
			await config.update(globalEmmyrcKey, desiredGlobalEmmyrcPath, vscode.ConfigurationTarget.Global);
		} catch {
			vscode.window.showWarningMessage(`Tarantool extension has been unable to update the global configuration of the EmmyLua extension with its specific annotations. Run 'Tarantool: Initialize VS Code extension...' to initialize the annotations per-project`);
			return;
		}
		try {
			await vscode.commands.executeCommand('emmy.restartServer');
		} catch {
			vscode.window.showWarningMessage(`Tarantool extension has updated the configuration but wasn't able to restart the EmmyLua extension. Please, restart it manually`);
			return;
		}
		vscode.window.showInformationMessage(`The EmmyLua extension has been updated with Tarantool-specific settings`);
	}
}

async function initVs() {
	const wsPath = utils.fetchWsFolder({ showWarning: true })?.uri.fsPath;
	if (!wsPath) {
		return;
	}

	const wsedit = new vscode.WorkspaceEdit();
	const filePath = vscode.Uri.file(`${wsPath}/${emmyrcFile}`);
	if (fs.existsSync(filePath.fsPath)) {
		const yes = "Yes";
		const ask = await vscode.window.showInformationMessage(`It seems like there is an existing LSP configuration in ${emmyrcFile} file. Overwrite it?`, yes, "No");
		if (ask !== yes)
			{return;}
	}
	wsedit.createFile(filePath, {
		overwrite: true,
		contents: Buffer.from(JSON.stringify(emmyrc, undefined, 2))
	});
	vscode.workspace.applyEdit(wsedit);
	vscode.window.showInformationMessage(`Created a new file: ${filePath.toString()}`);
}

function checkOnStartup() {
	function error(message: string) {
		vscode.window.showErrorMessage(`Error during Tarantool plugin initialization: ${message}. Try reinstalling the extension from the marketplace`);
		return false;
	}

	const brokenPaths = annotationsPaths.filter((path) => !fs.existsSync(path));
	if (brokenPaths.length > 0) {
		return error(`type annotations are not available at ${brokenPaths.join(', ')}`);
	}

	return true;
}

export function activate(context: vscode.ExtensionContext) {
	if (!checkOnStartup()) {
		return;
	}

	initGlobalEmmyrc();

	const commands = [
		{ name: 'init-vs', cb: initVs },
		{ name: 'create', cb: tt.create },
		{ name: 'init', cb: tt.init },
		{ name: 'start', cb: tt.start },
		{ name: 'stop', cb: tt.stop },
		{ name: 'stat', cb: tt.stat },
		{ name: 'restart', cb: tt.restart },
		{ name: 'install-ce', cb: tt.installCe },
	];

	commands.forEach((command) => {
		const commandName = `tarantool.${command.name}`;
		const vsCommand = vscode.commands.registerCommand(commandName, command.cb);
		context.subscriptions.push(vsCommand);
	});
}

export function deactivate() {}
