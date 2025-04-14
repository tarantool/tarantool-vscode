import * as vscode from 'vscode';
import * as tt from './tt';
import * as fs from 'fs';

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

async function initVs() {
	const file = vscode.window.activeTextEditor?.document.uri.fsPath;

	const wsedit = new vscode.WorkspaceEdit();
	const wsFolders = vscode.workspace.workspaceFolders?.map((folder) => folder.uri.fsPath);
	if (!wsFolders) {
		vscode.window.showWarningMessage('Please, open a project before running this command');
		return;
	}
	
	const wsPath = file ? wsFolders.find((folder) => file.startsWith(folder)) : wsFolders.at(0);
	if (!wsPath) {
		vscode.window.showWarningMessage('Please, open at least one folder within the workspace');
		return;
	}

	const emmyrcFile = '.emmyrc.json';
	const filePath = vscode.Uri.file(`${wsPath}/${emmyrcFile}`);
	if (fs.existsSync(filePath.fsPath)) {
		const yes = "Yes";
		const ask = await vscode.window.showInformationMessage(`It seems like there is an existing LSP configuration in ${emmyrcFile} file. Overwrite it?`, yes, "No");
		if (ask !== yes)
			{return;}
	}
	wsedit.createFile(filePath, {
		overwrite: true,
		contents: Buffer.from(JSON.stringify(emmyrc))
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
