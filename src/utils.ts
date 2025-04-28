import * as vscode from 'vscode';

export function fetchWsFolder(opts?: { showWarning?: boolean }): vscode.WorkspaceFolder | null {
	const file = vscode.window.activeTextEditor?.document.uri.fsPath;

	const wsFolders = vscode.workspace.workspaceFolders;
	if (!wsFolders) {
		if (opts?.showWarning) {
			vscode.window.showWarningMessage('Please, open a project before running this command');
		}
		return null;
	}
	
	const wsFolder = file ? wsFolders.find((folder) => file.startsWith(folder.uri.fsPath)) : wsFolders.at(0);
	if (!wsFolder) {
		if (opts?.showWarning) {
			vscode.window.showWarningMessage('Please, open at least one folder within the workspace');
		}
		return null;
	}

	return wsFolder;
}
