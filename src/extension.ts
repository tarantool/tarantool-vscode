import * as vscode from 'vscode';
import * as tt from './tt';

const emmyrc = {
	"runtime": {
		"version": "LuaJIT"
	},
	"workspace": {
		"library": [
			__dirname + "/../tarantool-emmylua/Library"
		]
	}
};

function initVs() {
	const wsedit = new vscode.WorkspaceEdit();
	const wsPath = vscode.workspace.workspaceFolders?.at(0)?.uri.fsPath;
	if (!wsPath) {
		vscode.window.showWarningMessage('Please, open project before running this command');
		return;
	}

	const filePath = vscode.Uri.file(`${wsPath}/.emmyrc.json`);
	wsedit.createFile(filePath, {
		ignoreIfExists: true,
		contents: Buffer.from(JSON.stringify(emmyrc))
	});
	vscode.workspace.applyEdit(wsedit);
	vscode.window.showInformationMessage(`Created a new file: ${filePath.toString()}`);
}

export function activate(context: vscode.ExtensionContext) {
	const commands = [
		{ name: 'init-vs', cb: initVs },
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
