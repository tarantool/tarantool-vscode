import * as vscode from 'vscode';
import commandExists = require('command-exists');


const TerminalLabel = 'Tarantool';

function getTerminal(): vscode.Terminal {
	const terminal = vscode.window.terminals.find(t => t.name === TerminalLabel) ||
		vscode.window.createTerminal(TerminalLabel);
	terminal.show(true);
	return terminal;
}

function isTerminalRunning(): boolean {
	const terminals = vscode.window.terminals;
	return terminals.find(t => t.name === TerminalLabel) !== undefined;
}

function cmd(body: string) {
	return async () => {
		commandExists('tt').then(() => {
			const t = getTerminal();
			t.sendText('tt ' + body);
		}).catch(function () {
			vscode.window.showErrorMessage('TT is not installed');
		});
	};
}


export const init = cmd('init');
export const start = cmd('start -i &');
export const stop = cmd('stop -y');
export const stat = cmd('status -p');
export const restart = cmd('restart -y');
