// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';
import * as tt from './tt';

const emmyrc = {
	"runtime": {
		"version": "LuaJIT"
	},
	"workspace": {
		"library": [
			__dirname + "/Library"
		]
	}
};

export function activate(context: vscode.ExtensionContext) {
	context.subscriptions.push(vscode.commands.registerCommand('tarantool-vscode.init-vs', () => {
		const wsedit = new vscode.WorkspaceEdit();
		const wsPath = vscode.workspace.workspaceFolders?.at(0)?.uri.fsPath; // gets the path of the first workspace folder
		if (!wsPath) {
			vscode.window.showWarningMessage('Please, open project before running this command');
			return;
		}
	
		const filePath = vscode.Uri.file(wsPath + '/.emmyrc.json');
		wsedit.createFile(filePath, {
			ignoreIfExists: true,
			contents: Buffer.from(JSON.stringify(emmyrc))
		});
		vscode.workspace.applyEdit(wsedit);
		vscode.window.showInformationMessage('Created a new file: ' + filePath.toString());
	}));

	context.subscriptions.push(vscode.commands.registerCommand('tarantool-vscode.init', tt.init));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool-vscode.start', tt.start));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool-vscode.stop', tt.stop));
}

export function deactivate() {}
