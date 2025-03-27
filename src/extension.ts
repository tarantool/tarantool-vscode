// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';

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
	const disposable = vscode.commands.registerCommand('tarantool-vscode.init', () => {
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
	});

	context.subscriptions.push(disposable);
}

export function deactivate() {}
