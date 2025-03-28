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

	context.subscriptions.push(vscode.commands.registerCommand('tarantool.init', tt.init));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool.start', tt.start));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool.stop', tt.stop));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool.restart', tt.restart));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool.stat', tt.stat));
	context.subscriptions.push(vscode.commands.registerCommand('tarantool.install-ce', tt.installCe));
}

export function deactivate() {}
