import * as vscode from 'vscode';
import * as path from 'path';

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

const dllPathTemplate = '{dllPath}';
const debuggerCodeSnippet = `-- Start of Tarantool debugger block. Remove after debugging.
do
    local old_cpath = package.cpath
    package.cpath = package.cpath .. ";${dllPathTemplate}"
    rawset(_G, 'tolua', false)
    rawset(_G, 'xlua', false)
    rawset(_G, 'emmyHelper', {})
    local dbg = require('emmy_core')
    local log = require('log')
    _G.emmyHelperInit()
    function init_debugger()
        dbg.tcpListen('localhost', 9966)
        dbg.waitIDE()
    end
    local ok, err = pcall(init_debugger)
    if ok then
        log.info('Set up Tarantool for debugging')
    else
        log.warn('Unable to start debugger: %s', err)
    end
    package.cpath  = old_cpath
end
-- End of Tarantool debugger block. Remove after debugging.
`;

export async function insertDebuggerCode() {
    const activeEditor = vscode.window.activeTextEditor;
    if (!activeEditor) {
        vscode.window.showWarningMessage(`You should have an active text editor window to insert Tarantool debugger code. Consider opening a file`);
        return;
    }
    const document = activeEditor.document;
    if (document.languageId !== 'lua') {
        vscode.window.showWarningMessage(`Tarantool Debugger code is supposed to be used within .lua files`);
        return;
    }

    let dllPath = '';
    const extensionPath = __dirname;
    const isWindows = process.platform === 'win32';
    const isMac = process.platform === 'darwin';
    const isLinux = process.platform === 'linux';
    if (isWindows) {
        const arch = await vscode.window.showQuickPick(['x64', 'x86']);
        if (!arch) {
            return;
        }
        dllPath = path.join(extensionPath, `debugger/emmy/windows/${arch}/?.dll`);
    } else if (isMac) {
        const arch = await vscode.window.showQuickPick(['x64', 'arm64']);
        if (!arch) {
            return;
        }
        dllPath = path.join(extensionPath, `debugger/emmy/mac/${arch}/emmy_core.dylib`);
    }
    else if (isLinux) {
        dllPath = path.join(extensionPath, `debugger/emmy/linux/emmy_core.so`);
    }

    const snippet = new vscode.SnippetString();
    snippet.appendText(debuggerCodeSnippet.replace(dllPathTemplate, dllPath.replace(/\\/g, '/')));
    activeEditor.insertSnippet(snippet);
}
