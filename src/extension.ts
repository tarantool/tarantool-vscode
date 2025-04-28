import * as vscode from 'vscode';
import * as tt from './tt';
import * as fs from 'fs';
import * as os from 'os';
import * as _ from 'lodash';
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

async function initGlobalEmmyrc() {
	const globalEmmyrcPath = `${os.homedir()}/${emmyrcFile}`;

	if (!fs.existsSync(globalEmmyrcPath)) {
		fs.writeFileSync(globalEmmyrcPath, JSON.stringify(emmyrc, undefined, 2));
		vscode.window.showInformationMessage(`Initialized ${globalEmmyrcPath} with Tarantool-specific settings`);
		return;
	}

	const f = fs.readFileSync(globalEmmyrcPath, 'utf8');
	const existingEmmyrc = JSON.parse(f);
	const upToDate = _.isMatch(existingEmmyrc, emmyrc);
	if (upToDate) {
		vscode.window.showInformationMessage(`${globalEmmyrcPath} is up to date`);
		return;
	}

	// TODO: Don't miss user-defined libraries.
	const mergedEmmyrc = _.merge(existingEmmyrc, emmyrc);

	fs.writeFileSync(globalEmmyrcPath, JSON.stringify(mergedEmmyrc, undefined, 2));
	vscode.window.showInformationMessage(`Updated existing ${globalEmmyrcPath} with actual Tarantool-specific configuration`);
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
